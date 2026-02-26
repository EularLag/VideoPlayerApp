//
//  PlaybackState.swift
//  VideoPlayerApp
//
//  播放状态和错误定义
//

import Foundation

/// 播放状态枚举
enum PlaybackState: Equatable {
    case idle       // 未加载视频
    case loading    // 加载中
    case ready      // 准备就绪
    case playing    // 播放中
    case paused     // 已暂停
    case stopped    // 已停止
    case error(Error) // 错误状态

    static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.ready, .ready),
             (.playing, .playing),
             (.paused, .paused),
             (.stopped, .stopped):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}

/// 播放器错误类型
enum PlayerError: LocalizedError {
    case invalidURL
    case fileNotFound
    case unsupportedFormat
    case playbackFailed(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的视频地址"
        case .fileNotFound:
            return "找不到视频文件"
        case .unsupportedFormat:
            return "不支持的视频格式"
        case .playbackFailed(let message):
            return "播放失败: \(message)"
        case .unknown:
            return "未知错误"
        }
    }
}
