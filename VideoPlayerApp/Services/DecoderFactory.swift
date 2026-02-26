//
//  DecoderFactory.swift
//  VideoPlayerApp
//
//  解码器工厂 - 根据视频格式选择合适的解码引擎
//

import Foundation
import AVFoundation

/// 播放引擎类型
enum PlaybackEngine {
    case avfoundation   // 使用原生 AVPlayer
    case ffmpeg        // 使用 FFmpeg 解码 + AVPlayer 渲染
}

/// 解码器工厂
struct DecoderFactory {

    /// 根据文件 URL 确定应该使用的播放引擎
    static func determineEngine(for url: URL) -> PlaybackEngine {
        let formatType = FormatDetector.detectFormat(url: url)

        switch formatType {
        case .nativeAVF:
            // 首先验证 AVFoundation 是否真的能播放
            if FormatDetector.canPlayWithAVFoundation(url: url) {
                return .avfoundation
            } else {
                // AVFoundation 声称支持但实际无法播放，降级到 FFmpeg
                return .ffmpeg
            }
        case .ffmpegFallback:
            return .ffmpeg
        case .unsupported:
            return .avfoundation // 默认使用 AVFoundation，让它处理错误
        }
    }

    /// 创建播放器项（根据选择的引擎）
    static func createPlayerItem(for url: URL, engine: PlaybackEngine) -> AVPlayerItem {
        switch engine {
        case .avfoundation:
            // 直接使用 URL 创建播放器项
            return AVPlayerItem(url: url)

        case .ffmpeg:
            // TODO: FFmpeg 模式
            // 方案1: FFmpeg 解码后写入临时文件，让 AVPlayer 播放
            // 方案2: 使用自定义 AVAssetResourceLoader
            // 方案3: 创建实时转换管道

            // 暂时使用原始 URL（FFmpeg 集成未完成）
            return AVPlayerItem(url: url)
        }
    }
}
