//
//  FormatDetector.swift
//  VideoPlayerApp
//
//  视频格式检测器 - 判断使用哪种解码引擎
//

import Foundation
import AVFoundation
import UniformTypeIdentifiers

/// 视频格式类型
enum VideoFormatType {
    case nativeAVF      // AVFoundation 原生支持
    case ffmpegFallback // 需要 FFmpeg 解码
    case unsupported    // 完全不支持
}

/// 视频格式检测器
struct FormatDetector {

    /// AVFoundation 原生支持的格式扩展名
    private static let avfSupportedExtensions: Set<String> = [
        "mp4", "mov", "m4v", "3gp", "3g2"
    ]

    /// AVFoundation 原生支持的 UTTypes
    private static let avfSupportedUTTypes: Set<UTType> = [
        .movie,
        .audiovisualContent,
        .quickTimeMovie,
        .mpeg4Movie,
        .appleProtectedMPEG4Video
    ]

    /// 检测文件格式类型
    static func detectFormat(url: URL) -> VideoFormatType {
        let fileExtension = url.pathExtension.lowercased()

        // 首先检查是否在原生支持列表中
        if avfSupportedExtensions.contains(fileExtension) {
            return .nativeAVF
        }

        // 尝试通过 UTType 判断
        if let utType = UTType(filenameExtension: fileExtension),
           avfSupportedUTTypes.contains(utType) {
            return .nativeAVF
        }

        // FFmpeg 支持的格式（更广泛）
        if ffmpegSupportedExtensions.contains(fileExtension) {
            return .ffmpegFallback
        }

        return .unsupported
    }

    /// FFmpeg 支持的格式扩展名（更广泛）
    private static let ffmpegSupportedExtensions: Set<String> = [
        // AVFoundation 也支持的
        "mp4", "mov", "m4v", "3gp", "3g2", "avi",
        // FFmpeg 额外支持的容器格式
        "mkv", "webm", "flv", "wmv", "rm", "rmvb",
        "ts", "mts", "m2ts", "vob", "ogv", "ogm", "drc",
        "gif", "gifv", "mng", "qt", "yuv",
        "asf", "amv", "m4p", "mpg", "mp2", "mpeg",
        "mpe", "mpv", "m2v", "svi", "mxf", "nsv",
        "f4v", "f4p", "f4a", "f4b",
        // 其他格式
        "divx", "xvid", "rv", "rm", "rmvb", "fla",
        "flr", "pxr", "viv", "svq", "aqt", "vivo"
    ]

    /// 验证文件是否可播放（通过 AVFoundation）
    static func canPlayWithAVFoundation(url: URL) -> Bool {
        let asset = AVAsset(url: url)
        return asset.isPlayable
    }

    /// 获取格式描述
    static func formatDescription(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "mkv": return "Matroska 视频 (需要 FFmpeg)"
        case "webm": return "WebM 视频 (需要 FFmpeg)"
        case "flv": return "Flash 视频 (需要 FFmpeg)"
        case "wmv": return "Windows Media 视频 (需要 FFmpeg)"
        case "rm", "rmvb": return "RealMedia 视频 (需要 FFmpeg)"
        case "avi": return "AVI 视频"
        case "mp4": return "MPEG-4 视频"
        case "mov": return "QuickTime 视频"
        case "m4v": return "iTunes 视频"
        default: return "视频文件"
        }
    }
}
