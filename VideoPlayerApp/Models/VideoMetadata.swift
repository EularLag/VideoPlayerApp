//
//  VideoMetadata.swift
//  VideoPlayerApp
//
//  视频元数据模型
//

import Foundation
import AVFoundation

/// 视频元数据
struct VideoMetadata {
    let url: URL
    let title: String
    let duration: CMTime
    let naturalSize: CGSize
    let isPlayable: Bool

    var durationInSeconds: Double {
        return CMTimeGetSeconds(duration)
    }

    /// 从URL加载元数据
    static func load(from url: URL) async throws -> VideoMetadata {
        let asset = AVAsset(url: url)

        // 异步加载元数据
        let (duration, isPlayable) = try await asset.load(.duration, .isPlayable)

        // 加载视频轨道
        let tracks = try await asset.loadTracks(withMediaType: .video)
        var size = CGSize.zero

        if let videoTrack = tracks.first {
            let (naturalSize, preferredTransform) = try await videoTrack.load(.naturalSize, .preferredTransform)

            // 根据视频旋转角度调整尺寸
            if abs(preferredTransform.a) == 0 && abs(preferredTransform.c) == 1 {
                size = CGSize(width: naturalSize.height, height: naturalSize.width)
            } else {
                size = naturalSize
            }
        }

        return VideoMetadata(
            url: url,
            title: url.lastPathComponent,
            duration: duration,
            naturalSize: size,
            isPlayable: isPlayable
        )
    }
}
