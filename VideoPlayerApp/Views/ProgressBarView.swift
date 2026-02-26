//
//  ProgressBarView.swift
//  VideoPlayerApp
//
//  进度条组件
//

import SwiftUI

/// 播放进度条视图
struct ProgressBarView: View {

    @Binding var progress: Double
    @Binding var currentTime: Double
    @Binding var totalDuration: Double
    let currentTimeString: String
    let totalDurationString: String
    let onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            // 时间标签
            HStack {
                Text(currentTimeString)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Text(totalDurationString)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景轨道
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.3))

                    // 已播放进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * displayProgress)

                    // 拖动指示器
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: geometry.size.width * displayProgress - 6)
                        .shadow(radius: 2)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let newProgress = min(max(0, value.location.x / geometry.size.width), 1)
                            dragProgress = newProgress
                        }
                        .onEnded { _ in
                            isDragging = false
                            onSeek(dragProgress)
                        }
                )
            }
            .frame(height: 6)
        }
    }

    private var displayProgress: Double {
        isDragging ? dragProgress : progress
    }
}
