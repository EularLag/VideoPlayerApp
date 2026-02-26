//
//  VideoPlayerApp.swift
//  VideoPlayerApp
//
//  应用入口
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct VideoPlayerApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("打开视频文件...") {
                    appDelegate.openFile()
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(replacing: .pasteboard) {
                Button("快进") {
                    appDelegate.forward()
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
    }
}

/// 应用代理
class AppDelegate: NSObject, NSApplicationDelegate {

    weak var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            self.window = window
            window.setContentSize(Constants.defaultWindowSize)
            window.minSize = Constants.minimumWindowSize
            window.center()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = Constants.supportedUTTypes.compactMap { UTType($0) }
        panel.title = "选择视频文件"
        panel.prompt = "打开"

        if panel.runModal() == .OK, let url = panel.url {
            // 通知主窗口加载视频
            NotificationCenter.default.post(name: .loadVideo, object: nil, userInfo: ["url": url])
        }
    }

    func forward() {
        NotificationCenter.default.post(name: .forward, object: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let loadVideo = Notification.Name("loadVideo")
    static let forward = Notification.Name("forward")
}
