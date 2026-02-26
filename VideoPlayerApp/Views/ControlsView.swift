//
//  ControlsView.swift
//  VideoPlayerApp
//
//  播放控制界面
//

import SwiftUI

/// 播放器控制视图
struct ControlsView: View {

    @ObservedObject var viewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: 16) {
            // 进度条
            ProgressBarView(
                progress: $viewModel.playbackProgress,
                currentTime: $viewModel.currentTime,
                totalDuration: $viewModel.totalDuration,
                currentTimeString: viewModel.currentTimeString,
                totalDurationString: viewModel.totalDurationString,
                onSeek: { progress in
                    viewModel.seekToProgress(progress)
                }
            )
            .padding(.horizontal, 20)

            // 控制按钮
            HStack(spacing: 20) {
                // 快退按钮
                Button(action: { viewModel.backward() }) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.hasVideo)

                // 播放/暂停按钮
                Button(action: { viewModel.togglePlayPause() }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.hasVideo)

                // 快进按钮
                Button(action: { viewModel.forward() }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.hasVideo)

                Spacer()

                // 音量控制
                HStack(spacing: 8) {
                    Image(systemName: viewModel.volume > 0 ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            viewModel.toggleMute()
                        }

                    Slider(value: $viewModel.volume, in: 0...1) { editing in
                        if !editing {
                            viewModel.setVolume(viewModel.volume)
                        }
                    }
                    .frame(width: 80)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
