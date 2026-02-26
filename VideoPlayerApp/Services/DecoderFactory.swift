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
            // FFmpeg 模式：转换为临时文件或使用自定义资源加载器
            if let convertedURL = convertWithFFmpeg(url: url) {
                return AVPlayerItem(url: convertedURL)
            } else {
                // 转换失败，返回原始 URL
                return AVPlayerItem(url: url)
            }
        }
    }

    /// 使用 FFmpeg 转换视频文件为兼容格式
    ///
    /// 此方法使用 FFmpeg CLI 将不兼容的视频格式转换为 MP4 格式
    /// 转换后的文件保存在临时目录中
    ///
    /// - Parameter url: 原始视频文件 URL
    /// - Returns: 转换后的视频文件 URL，如果转换失败则返回 nil
    private static func convertWithFFmpeg(url: URL) -> URL? {
        // 检查 FFmpeg 是否可用
        guard isFFmpegAvailable() else {
            print("FFmpeg 不可用，请安装: brew install ffmpeg")
            return nil
        }

        // 创建临时文件路径
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("converted_\(UUID().uuidString).mp4")

        // 构建 FFmpeg 命令
        // -i: 输入文件
        // -c:v libx264: 视频编码器 (H.264)
        // -c:a aac: 音频编码器 (AAC)
        // -preset ultrafast: 使用最快预设（牺牲一些质量）
        // -movflags +faststart: 优化网络播放
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ffmpeg")
        process.arguments = [
            "-i", url.path,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "ultrafast",
            "-movflags", "+faststart",
            "-y", // 覆盖输出文件
            tempURL.path
        ]

        // 执行转换
        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                print("FFmpeg 转换成功: \(tempURL.path)")
                return tempURL
            } else {
                print("FFmpeg 转换失败，退出码: \(process.terminationStatus)")
                return nil
            }
        } catch {
            print("FFmpeg 转换出错: \(error.localizedDescription)")
            return nil
        }
    }

    /// 检查 FFmpeg 是否可用
    private static func isFFmpegAvailable() -> Bool {
        let paths = [
            "/usr/local/bin/ffmpeg",
            "/opt/homebrew/bin/ffmpeg",
            "/opt/homebrew/opt/ffmpeg/bin/ffmpeg"
        ]

        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // 尝试使用 which 命令
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        task.arguments = ["ffmpeg"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// 清理临时转换文件
    static func cleanupConvertedFile(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - FFmpeg 进度监控（可选扩展）

extension DecoderFactory {
    /// 使用 FFmpeg 转换视频文件（带进度回调）
    static func convertWithFFmpeg(
        url: URL,
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard isFFmpegAvailable() else {
            completion(.failure(PlayerError.unsupportedFormat))
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("converted_\(UUID().uuidString).mp4")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/local/bin/ffmpeg")
        process.arguments = [
            "-i", url.path,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "ultrafast",
            "-movflags", "+faststart",
            "-progress", "pipe:1",
            "-nostats",
            "-y",
            tempURL.path
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // 读取进度
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8) {
                // 解析 FFmpeg 进度输出
                // 格式: out_time_ms=12345
                if let range = output.range(of: "out_time_ms=") {
                    let timeStr = output[range.upperBound...]
                        .components(separatedBy: .newlines)[0]
                        .trimmingCharacters(in: .whitespaces)
                    if let timeMs = Double(timeStr) {
                        // 假设 60 秒的视频，计算进度
                        let progress = min(timeMs / 60000.0, 1.0)
                        DispatchQueue.main.async {
                            progressHandler(progress)
                        }
                    }
                }
            }
        }

        do {
            try process.run()

            process.terminationHandler = { process in
                if process.terminationStatus == 0 {
                    completion(.success(tempURL))
                } else {
                    completion(.failure(PlayerError.unknown))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
