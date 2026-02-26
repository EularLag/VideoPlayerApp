//
//  PlayerViewModel.swift
//  VideoPlayerApp
//
//  核心播放器 ViewModel
//

import Foundation
import AVFoundation
import Combine

/// 播放器 ViewModel
@MainActor
class PlayerViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 是否正在播放
    @Published var isPlaying: Bool = false

    /// 当前播放时间（秒）
    @Published var currentTime: Double = 0.0

    /// 总时长（秒）
    @Published var totalDuration: Double = 0.0

    /// 音量 (0.0 - 1.0)
    @Published var volume: Float = Constants.defaultVolume

    /// 当前时间字符串
    @Published var currentTimeString: String = "0:00"

    /// 总时长字符串
    @Published var totalDurationString: String = "0:00"

    /// 是否已加载视频
    @Published var hasVideo: Bool = false

    /// 视频元数据
    @Published var metadata: VideoMetadata?

    /// 当前播放状态
    @Published var playbackState: PlaybackState = .idle

    /// 播放进度 (0.0 - 1.0)
    @Published var playbackProgress: Double = 0.0

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupBindings()
    }

    nonisolated deinit {
        // 清理资源
        Task { @MainActor in
            self.player?.pause()
            if let observer = self.timeObserver, let player = self.player {
                player.removeTimeObserver(observer)
            }
            self.statusObserver?.invalidate()
            self.player?.replaceCurrentItem(with: nil)
        }
    }

    // MARK: - Setup

    private func setupBindings() {
        // 监听播放时间变化，更新进度
        $currentTime
            .combineLatest($totalDuration)
            .sink { [weak self] currentTime, totalDuration in
                guard let self = self else { return }
                self.currentTimeString = VideoFormatter.formatTime(currentTime)
                self.playbackProgress = totalDuration > 0 ? currentTime / totalDuration : 0
            }
            .store(in: &cancellables)

        // 监听总时长变化，更新时间字符串
        $totalDuration
            .sink { [weak self] duration in
                guard let self = self else { return }
                self.totalDurationString = VideoFormatter.formatTime(duration)
            }
            .store(in: &cancellables)
    }

    // MARK: - Video Loading

    /// 加载视频文件
    func loadVideo(url: URL) async {
        playbackState = .loading

        do {
            // 加载视频元数据
            let metadata = try await VideoMetadata.load(from: url)
            self.metadata = metadata

            // 创建播放器项
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem

            // 创建或更新播放器
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }

            // 设置音量
            player?.volume = volume

            // 监听播放器项状态
            try await waitForPlayerReady()

            // 更新属性
            self.totalDuration = metadata.durationInSeconds
            self.currentTime = 0
            self.hasVideo = true
            self.playbackState = .ready

            setupTimeObserver()

        } catch {
            self.playbackState = .error(error)
            self.hasVideo = false
            print("加载视频失败: \(error.localizedDescription)")
        }
    }

    private func waitForPlayerReady() async throws {
        guard let playerItem = playerItem else {
            throw PlayerError.unknown
        }

        // 如果已经准备好，直接返回
        if playerItem.status == .readyToPlay {
            return
        }

        // 等待播放器项状态变为就绪
        try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false

            statusObserver = playerItem.observe(\.status) { item, _ in
                guard !hasResumed else { return }

                if item.status == .readyToPlay {
                    hasResumed = true
                    continuation.resume()
                } else if item.status == .failed {
                    hasResumed = true
                    continuation.resume(throwing: item.error ?? PlayerError.unknown)
                }
            }
        }

        statusObserver = nil
    }

    // MARK: - Playback Controls

    /// 播放
    func play() {
        player?.play()
        isPlaying = true
        playbackState = .playing
    }

    /// 暂停
    func pause() {
        player?.pause()
        isPlaying = false
        playbackState = .paused
    }

    /// 切换播放/暂停
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// 停止播放
    func stop() {
        pause()
        seekTo(time: 0)
        playbackState = .stopped
    }

    /// 跳转到指定时间
    func seekTo(time: Double) {
        guard let player = player, totalDuration > 0 else { return }

        let clampedTime = max(0, min(time, totalDuration))
        let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)

        player.seek(to: cmTime) { [weak self] finished in
            if finished {
                Task { @MainActor in
                    self?.currentTime = clampedTime
                }
            }
        }
    }

    /// 跳转到指定进度位置
    func seekToProgress(_ progress: Double) {
        let time = progress * totalDuration
        seekTo(time: time)
    }

    /// 快进 10 秒
    func forward() {
        let newTime = currentTime + 10
        seekTo(time: newTime)
    }

    /// 快退 10 秒
    func backward() {
        let newTime = currentTime - 10
        seekTo(time: newTime)
    }

    // MARK: - Volume Control

    /// 设置音量
    func setVolume(_ volume: Float) {
        let clampedVolume = max(0, min(volume, Constants.maximumVolume))
        self.volume = clampedVolume
        player?.volume = clampedVolume
    }

    /// 静音/取消静音
    func toggleMute() {
        if player?.volume == 0 {
            player?.volume = volume
        } else {
            player?.volume = 0
        }
    }

    // MARK: - Time Observer

    private func setupTimeObserver() {
        removeTimeObserver()

        guard let player = player else { return }

        let interval = CMTime(seconds: Constants.progressUpdateInterval, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = CMTimeGetSeconds(time)
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    // MARK: - Public Access

    /// 获取 AVPlayer 实例（用于 PlayerView）
    func getPlayer() -> AVPlayer? {
        return player
    }
}
