# FileConverter

**Offline file format converter for macOS.** Convert images, video, audio, and documents locally without limits or subscriptions.

## ✅ Status: Production Ready

- All tools installed and verified ✅
- File conversion tested and working ✅  
- No file limits or subscriptions ✅
- 100% offline operation ✅

---

## Quick Start

**Convert a file:**
```bash
# JPEG to PNG
ffmpeg -i photo.jpg photo.png -y

# MP4 to MOV
ffmpeg -i video.mp4 video.mov -y

# Compress PDF
gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=out.pdf in.pdf
```

**See [SETUP.md](SETUP.md) for detailed examples and complete usage guide.**

---

## Features

- 🎯 Convert images, video, audio, and documents offline
- 📦 No file limits – fully featured from day 1
- ⚙️ Config-based converters – easily extensible
- 🚀 Fast conversion using industry-standard tools
- 🔓 Open source (MIT license)

## Supported Formats

- **Images:** JPEG, PNG, WebP, GIF
- **Video:** MP4, MOV, AVI, MKV
- **Audio:** MP3, WAV, AAC, FLAC
- **Documents:** PDF (compression)

## Requirements

- macOS 13.0 or later
- Tools (pre-installed): ffmpeg, cwebp, exiftool, ghostscript

## Installation & Setup

See **[SETUP.md](SETUP.md)** for:
- Complete setup guide
- Detailed conversion examples
- Batch processing scripts
- CLI usage

## Build from Source

```bash
cd ~/FileConverter
swift build -c release
```

Executable: `.build/release/fileconverter`

## Architecture

```
Core (FileConverterCore)
  ├── Models: Converter, ConversionJob
  ├── Services: ConfigLoader, ProcessManager, ConverterEngine
  └── Resources: converters.yaml

CLI (FileConverterCLI)
  └── main.swift: Command-line interface

GUI (Future)
  └── SwiftUI-based graphical interface
```

## Adding Custom Converters

Edit `~/.fileconverter/converters.yaml`:

```yaml
converters:
  - id: "custom-id"
    name: "Custom Format"
    category: "custom"
    inputFormats: ["in"]
    outputFormats: ["out"]
    tool: "tool-name"
    command: "tool-name {input} -o {output}"
    options: []
```

## Contributing

Pull requests welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) before submitting.

## License

MIT – See [LICENSE](LICENSE) for details.

---

**Created:** October 2026 | **Status:** ✅ Fully functional and tested
