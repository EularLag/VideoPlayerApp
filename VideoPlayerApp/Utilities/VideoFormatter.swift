//
//  VideoFormatter.swift
//  VideoPlayerApp
//
//  时间格式化工具
//

import Foundation

/// 视频时间格式化工具
struct VideoFormatter {

    /// 将秒数转换为时间字符串 (格式: M:SS 或 H:MM:SS)
    static func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else {
            return "0:00"
        }

        let totalSeconds = Int(max(0, seconds))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    /// 将时间字符串转换为秒数
    static func parseTime(_ timeString: String) -> Double? {
        let components = timeString.split(separator: ":").compactMap { Int($0) }

        switch components.count {
        case 2: // M:SS
            guard components.count == 2 else { return nil }
            return Double(components[0] * 60 + components[1])
        case 3: // H:MM:SS
            guard components.count == 3 else { return nil }
            return Double(components[0] * 3600 + components[1] * 60 + components[2])
        default:
            return nil
        }
    }
}
