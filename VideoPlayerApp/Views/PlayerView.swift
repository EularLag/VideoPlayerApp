//
//  PlayerView.swift
//  VideoPlayerApp
//
//  视频显示层 - NSViewRepresentable 封装
//

import SwiftUI
import AVFoundation

/// 视频播放视图 - 使用 NSViewRepresentable 封装 AVPlayerLayer
struct PlayerView: NSViewRepresentable {

    let player: AVPlayer?
    @Binding var videoSize: CGSize

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true

        let playerLayer = AVPlayerLayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect

        view.layer = playerLayer
        context.coordinator.playerLayer = playerLayer

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        guard let playerLayer = nsView.layer as? AVPlayerLayer else { return }

        if playerLayer.player !== player {
            playerLayer.player = player
        }

        // 更新视频尺寸
        if let player = player,
           let currentItem = player.currentItem,
           !currentItem.asset.isPlayable {

            // 等待资源可用
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

/// 视频容器视图 - 保持视频宽高比
struct VideoContainerView: View {
    let player: AVPlayer?
    @Binding var videoSize: CGSize

    var body: some View {
        GeometryReader { geometry in
            PlayerView(player: player, videoSize: $videoSize)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
