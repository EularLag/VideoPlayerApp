//
//  ContentView.swift
//  VideoPlayerApp
//
//  主界面
//

import SwiftUI

/// 主内容视图
struct ContentView: View {

    @StateObject private var viewModel = PlayerViewModel()
    @State private var videoSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            // 视频显示区域
            ZStack {
                if viewModel.hasVideo, let player = viewModel.getPlayer() {
                    VideoContainerView(player: player, videoSize: $videoSize)
                } else if viewModel.isConverting {
                    // 转换进度视图
                    conversionProgressView
                } else {
                    // 空状态视图
                    emptyStateView
                }
            }
            .frame(minWidth: 480, minHeight: 270)

            // 控制区域
            if viewModel.hasVideo {
                ControlsView(viewModel: viewModel)
            }
        }
        .frame(minWidth: Constants.minimumWindowSize.width, minHeight: Constants.minimumWindowSize.height)
    }

    /// 转换进度视图
    private var conversionProgressView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(viewModel.isConverting ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.isConverting)

            VStack(spacing: 12) {
                Text("正在转换视频")
                    .font(.title2)
                    .fontWeight(.medium)

                Text(viewModel.conversionStatus.isEmpty ? "准备中..." : viewModel.conversionStatus)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            // 进度条
            ProgressView(value: viewModel.conversionProgress)
                .frame(width: 200)

            Text("\(Int(viewModel.conversionProgress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "film.stack")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("视频播放器")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("支持格式：MP4, MOV, M4V, MKV, WebM, FLV 等")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            FilePickerView { url in
                Task {
                    await viewModel.loadVideo(url: url)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
