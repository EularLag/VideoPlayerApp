//
//  FilePickerView.swift
//  VideoPlayerApp
//
//  文件选择器
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// 文件选择器视图
struct FilePickerView: View {

    let onFileSelected: (URL) -> Void

    var body: some View {
        Button(action: openFilePicker) {
            Label("选择视频文件", systemImage: "doc.badge.plus")
                .font(.body)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        // 设置允许的文件类型
        panel.allowedContentTypes = [
            .movie,
            .audiovisualContent,
            .quickTimeMovie,
            .mpeg4Movie,
            .mpeg2Video,
            .appleProtectedMPEG4Video,
            .avi
        ]

        panel.title = "选择视频文件"
        panel.prompt = "打开"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                onFileSelected(url)
            }
        }
    }
}
