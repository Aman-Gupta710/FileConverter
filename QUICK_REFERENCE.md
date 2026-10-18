# FileConverter - Quick Reference

**Offline file conversion for macOS** | ✅ Fully functional | No limits | No subscriptions

---

## 🚀 Quick Start (60 seconds)

```bash
# 1. Clone repository
git clone https://github.com/Aman-Gupta710/FileConverter.git
cd FileConverter

# 2. Install tools (if not already installed)
brew install ffmpeg cwebp exiftool ghostscript

# 3. Convert a file
ffmpeg -i photo.jpg photo.png -y
```

Done! ✅

---

## 📋 Most Common Commands

### Images
```bash
ffmpeg -i input.jpg output.png -y              # JPEG → PNG
ffmpeg -i input.png output.jpg -y              # PNG → JPEG
cwebp input.jpg -o output.webp                 # JPG → WebP
ffmpeg -i input.jpg -vf scale=800:600 out.png  # Resize while converting
```

### Video
```bash
ffmpeg -i input.mp4 output.mov -y              # MP4 → MOV
ffmpeg -i input.mov output.mp4 -y              # MOV → MP4
ffmpeg -i input.mp4 -q:v 5 output.mp4 -y       # Change quality
```

### Audio
```bash
ffmpeg -i input.mp3 output.wav -y              # MP3 → WAV
ffmpeg -i input.wav output.mp3 -y              # WAV → MP3
ffmpeg -i input.wav -q:a 5 output.mp3 -y       # Change quality
```

### PDF
```bash
# Compress PDF
gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile=out.pdf in.pdf
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview |
| [GETTING_STARTED.md](GETTING_STARTED.md) | Complete user guide |
| [SETUP.md](SETUP.md) | Installation & examples |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Developer guide |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | This file |

---

## 🔨 Build & Development

```bash
# Build from source
swift build -c release

# Executable location
.build/release/fileconverter

# List converters
.build/release/fileconverter list

# Convert using CLI
.build/release/fileconverter convert input.jpg output.png
```

---

## 🛠️ Supported Tools & Formats

### Tools
- **ffmpeg** - Video, audio, image conversion
- **cwebp** - WebP image encoding
- **exiftool** - Metadata handling
- **ghostscript** - PDF manipulation

### Formats

| Type | Input | Output |
|------|-------|--------|
| **Image** | JPG, PNG, GIF, WebP | PNG, JPG, WebP |
| **Video** | MP4, MOV, AVI, MKV | MP4, MOV |
| **Audio** | MP3, WAV, AAC, FLAC | MP3, WAV |
| **Document** | PDF | PDF (compressed) |

---

## 💡 Tips & Tricks

### Batch Processing
```bash
# Convert all JPGs to PNG
for file in *.jpg; do
    ffmpeg -i "$file" "${file%.jpg}.png" -y
done
```

### Quality Settings
```bash
ffmpeg -i input.mp3 -q:a 5 output.mp3 -y       # Audio quality (0-9, 0=best)
ffmpeg -i input.jpg -q:v 2 output.jpg -y       # Image quality (2-31, 2=best)
ffmpeg -i input.mp4 -preset fast output.mp4 -y # Video speed (fast/medium/slow)
```

### Extract Audio from Video
```bash
ffmpeg -i video.mp4 -q:a 0 -map a audio.mp3
```

### Extract Video from Audio
```bash
ffmpeg -loop 1 -i image.png -i audio.mp3 -c:v libx264 -c:a aac -shortest output.mp4 -y
```

---

## ❓ Troubleshooting

| Problem | Solution |
|---------|----------|
| Command not found | `brew install ffmpeg cwebp exiftool ghostscript` |
| File not found | Check input file exists: `ls input.jpg` |
| No converters found (CLI) | Copy config: `mkdir -p ~/.fileconverter && cp Core/Resources/converters.yaml ~/.fileconverter/` |
| Permission denied | `chmod +x .build/release/fileconverter` |
| Build fails | `rm -rf .build && swift build -c release` |

---

## 📖 For Users

1. **New to FileConverter?** → Start with [GETTING_STARTED.md](GETTING_STARTED.md)
2. **Need examples?** → Check [SETUP.md](SETUP.md)
3. **Want to contribute?** → Read [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 👥 Community

- **Questions?** Open an issue on GitHub
- **Found a bug?** Report with reproduction steps
- **Want to contribute?** See [CONTRIBUTING.md](CONTRIBUTING.md)
- **Have an idea?** Start a discussion

---

## 📄 License

MIT License - Use freely, modify, distribute.

---

## ✅ Status

| Feature | Status |
|---------|--------|
| Core conversion engine | ✅ Complete |
| Image conversion | ✅ Working |
| Video conversion | ✅ Working |
| Audio conversion | ✅ Working |
| PDF compression | ✅ Working |
| CLI tool | ✅ Built |
| Config-based converters | ✅ Implemented |
| GUI (macOS) | 🚧 Planned |
| Batch processing | 🚧 Planned |
| Windows support | 🚧 Future |

---

**Last Updated:** October 2026  
**Repository:** https://github.com/Aman-Gupta710/FileConverter  
**Made with ❤️ for the community**
