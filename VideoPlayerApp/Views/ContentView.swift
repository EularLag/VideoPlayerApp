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

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "film.stack")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Text("视频播放器")
                    .font(.title2)
                    .fontWeight(.medium)

                Text("选择一个视频文件开始播放")
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
