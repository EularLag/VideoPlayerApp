# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A native macOS video player application built with **SwiftUI** and **AVFoundation**, following the **MVVM architecture pattern**. Target platform: macOS 13.0+.

## Build Commands

```bash
# Using Xcode (recommended for GUI debugging)
open VideoPlayerApp.xcodeproj
# Then press Cmd+R to build and run

# Using Swift Package Manager
swift build
swift run

# Directly run the compiled app
open /Users/rye/Library/Developer/Xcode/DerivedData/VideoPlayerApp-*/Build/Products/Debug/VideoPlayerApp.app
```

## Architecture: MVVM Pattern

The app follows a strict MVVM separation:

- **Models**: `PlaybackState` (enum with Equatable), `VideoMetadata` (async loading via AVFoundation)
- **ViewModels**: `PlayerViewModel` (@MainActor class with @Published properties)
- **Views**: SwiftUI views with NSViewRepresentable for AVPlayerLayer integration

### Key Architecture Patterns

1. **NSViewRepresentable Bridge**: `PlayerView.swift` wraps `AVPlayerLayer` for SwiftUI using NSViewRepresentable with a Coordinator pattern
2. **MainActor Isolation**: `PlayerViewModel` is marked `@MainActor`; its `deinit` uses `nonisolated` with Task for cleanup
3. **Async/Await Video Loading**: `VideoMetadata.load(from:)` uses modern AVFoundation async APIs (`asset.load()`)
4. **Continuation-Based Waiting**: `waitForPlayerReady()` uses `withCheckedThrowingContinuation` with a `hasResumed` guard flag to prevent double-resume

## Critical Implementation Details

### File Picker
- Uses `NSOpenPanel.begin { response in }` async API (not `runModal()`)
- Access selected file via `panel.url` (not `panel.urls`)
- Supported UTTypes: `.movie`, `.audiovisualContent`, `.quickTimeMovie`, `.mpeg4Movie`, `.mpeg2Video`

### PlayerViewModel Lifecycle
```
init() -> setupBindings()
loadVideo(url:) -> playbackState = .loading -> create AVPlayerItem -> waitForPlayerReady() -> hasVideo = true
deinit -> nonisolated -> Task { @MainActor in cleanup }
```

### Time Observer Pattern
- Uses `AVPlayer.addPeriodicTimeObserver()` with `.main` queue
- Must call `removeTimeObserver()` before setting new observer or in deinit
- Store observer reference in `private var timeObserver: Any?`

### Common Pitfalls

1. **Don't use `onChange(of:initial:_:)`** - requires macOS 14.0+, but project targets 13.0
2. **Continuation double-resume** - always guard with `hasResumed` flag in async continuations
3. **UTType availability** - not all UTTypes exist (e.g., `.m4v`, `.avi` may not be available)
4. **Info.plist in resources** - don't add to Copy Bundle Resources build phase

## File Structure

```
VideoPlayerApp/
├── VideoPlayerApp.swift      # @main entry point, AppDelegate
├── Models/                    # Data models
│   ├── PlaybackState.swift   # Enum: idle, loading, ready, playing, paused, stopped, error
│   └── VideoMetadata.swift   # Struct with async load(from:) method
├── ViewModels/
│   └── PlayerViewModel.swift  # @MainActor ObservableObject - core player logic
├── Views/
│   ├── ContentView.swift      # Main view, empty state + conditional controls
│   ├── PlayerView.swift       # NSViewRepresentable for AVPlayerLayer
│   ├── ControlsView.swift     # Play/pause, seek, volume controls
│   ├── ProgressBarView.swift  # Draggable progress bar
│   └── FilePickerView.swift   # NSOpenPanel wrapper
└── Utilities/
    ├── Constants.swift        # App constants (window sizes, supported formats)
    └── VideoFormatter.swift   # Time formatting (seconds -> "M:SS" or "H:MM:SS")
```

## State Management Flow

1. User selects file via `FilePickerView`
2. `onFileSelected(url)` calls `viewModel.loadVideo(url:)`
3. `loadVideo()` sets `playbackState = .loading`, loads metadata, creates AVPlayer
4. `waitForPlayerReady()` observes `.status` KVO, resumes continuation when ready
5. On success: sets `hasVideo = true`, `totalDuration`, `playbackState = .ready`
6. ContentView conditionally shows `VideoContainerView` and `ControlsView`
