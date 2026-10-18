# FileConverter CLI - Quick Start Guide

## Installation

After building, the `fileconverter` tool is located at:
```
~/.build/release/fileconverter
```

To make it easily accessible, add it to your PATH:
```bash
ln -s $(pwd)/.build/release/fileconverter /usr/local/bin/fileconverter
```

Then you can use it from anywhere:
```bash
fileconverter --help
```

---

## Usage

### List Available Converters
```bash
fileconverter list
```

### Convert a File
```bash
fileconverter convert <input-file> <output-file>
```

**Examples:**
```bash
# Convert JPEG to PNG
fileconverter convert photo.jpg photo.png

# Convert MP4 to MOV
fileconverter convert video.mp4 video.mov

# Convert MP3 to WAV
fileconverter convert music.mp3 music.wav

# Compress PDF
fileconverter convert document.pdf document-compressed.pdf
```

---

## Supported Formats

### Images
- Input: JPEG, PNG, WebP, GIF
- Output: PNG, WebP, JPEG

### Video
- Input: MP4, MOV, AVI, MKV
- Output: MP4, MOV

### Audio
- Input: MP3, WAV, AAC, FLAC
- Output: MP3, WAV

### Documents
- Input: PDF
- Output: PDF (compressed)

---

## System Requirements

- macOS 13.0 or later
- External tools installed via Homebrew:
  - ffmpeg
  - cwebp (webp)
  - exiftool
  - ghostscript (gs)

All tools are already installed on your system! ✅

---

## Troubleshooting

### Command not found
Make sure you've created the symlink:
```bash
ln -s $(pwd)/.build/release/fileconverter /usr/local/bin/fileconverter
```

### File not found error
Use the full path to your file:
```bash
fileconverter convert /full/path/to/input.jpg /full/path/to/output.png
```

### Conversion failed
Make sure the input format is supported:
```bash
fileconverter list
```

---

## Next Steps

1. **Test a conversion:** `fileconverter convert test.jpg test.png`
2. **Create shell aliases** for frequently used conversions
3. **Integrate into scripts** for batch processing
4. **When Xcode becomes available:** Build the full GUI version

---

For more info: https://github.com/Aman-Gupta710/FileConverter
