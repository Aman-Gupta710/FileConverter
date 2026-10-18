# FileConverter

A native macOS application for offline file format conversion without limits or subscriptions.

## Features

- 🎯 Convert images, video, audio, and documents offline
- 📦 No file limits – fully featured from day 1
- ⚙️ Config-based converters – easily add new formats
- 🚀 Drag-and-drop simplicity
- 📊 Batch processing with progress tracking
- 🔓 Open source (MIT license)

## Supported Formats

- **Images:** JPEG, PNG, WebP, GIF
- **Video:** MP4, MOV, AVI, MKV
- **Audio:** MP3, WAV, AAC, FLAC
- **Documents:** PDF compression

## Requirements

- macOS 13.0 or later
- External tools: ffmpeg, cwebp, exiftool (bundled or installed via Homebrew)

## Installation

1. Clone repository
2. Open `FileConverter.xcodeproj` in Xcode
3. Build and run

## Build Instructions

```bash
xcodebuild -scheme FileConverter -configuration Release
```

## Testing

```bash
xcodebuild test -scheme FileConverter
```

## Architecture

- **Models:** Data structures (Converter, ConversionJob, etc.)
- **Services:** Core logic (ConfigLoader, ProcessManager, ConverterEngine, JobQueue)
- **Views:** SwiftUI components
- **Resources:** Default converter configurations

## Adding Custom Converters

Edit `~/Library/Application Support/FileConverter/converters.yaml`:

```yaml
converters:
  - id: "custom-converter"
    name: "My Custom Format"
    category: "custom"
    inputFormats: ["input"]
    outputFormats: ["output"]
    tool: "mytool"
    command: "mytool {input} {output}"
    options: []
```

## License

MIT – See LICENSE file for details.

## Contributing

Pull requests welcome! Please review CONTRIBUTING.md before submitting.
