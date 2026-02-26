//
//  Constants.swift
//  VideoPlayerApp
//
//  应用常量定义
//

import Foundation
import AVFoundation

/// 应用常量
enum Constants {
    /// 支持的视频格式
    static let supportedVideoTypes: [String] = [
        "mp4",   // MPEG-4 视频
        "mov",   // QuickTime 视频
        "m4v",   // iTunes 视频
        "avi",   // AVI 视频
        "mkv",   // Matroska 视频
        "flv",   // Flash 视频
        "wmv",   // Windows Media 视频
        "webm",  // WebM 视频
        "m3u8",  // HLS 流媒体
        "mpg",   // MPEG 视频
        "mpeg"   // MPEG 视频
    ]

    /// UTI 类型
    static let supportedUTTypes: [String] = [
        "public.movie",
        "public.audiovisual-content",
        "com.apple.quicktime-movie",
        "com.apple.m4v-video",
        "public.mpeg-4",
        "public.avi",
        "public.matroska"
    ]

    /// 默认窗口尺寸
    static let defaultWindowSize = CGSize(width: 960, height: 540)

    /// 最小窗口尺寸
    static let minimumWindowSize = CGSize(width: 480, height: 270)

    /// 进度更新频率（秒）
    static let progressUpdateInterval: Double = 0.1

    /// 默认音量
    static let defaultVolume: Float = 1.0

    /// 最大音量
    static let maximumVolume: Float = 1.0

    /// 缓冲区大小（秒）
    static let preferredBufferDuration: Double = 30.0
}
