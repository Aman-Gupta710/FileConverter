# Getting Started with FileConverter

A complete guide for users and contributors.

---

## 📥 For Users: How to Use FileConverter

### Method 1: Clone and Use (Recommended for Most Users)

#### Step 1: Clone the Repository
```bash
git clone https://github.com/Aman-Gupta710/FileConverter.git
cd FileConverter
```

#### Step 2: Install Required Tools
FileConverter uses these external tools. Install via Homebrew:

```bash
brew install ffmpeg cwebp exiftool ghostscript
```

**Verify installation:**
```bash
ffmpeg -version
cwebp -version
exiftool -ver
gs -version
```

#### Step 3: Build FileConverter (Optional)
To use the CLI tool:

```bash
swift build -c release
```

The executable will be at: `.build/release/fileconverter`

#### Step 4: Start Converting

**Option A: Using Direct Tool Commands (No Build Needed)**

The easiest way — no compilation required:

```bash
# JPEG to PNG
ffmpeg -i input.jpg output.png -y

# PNG to JPEG
ffmpeg -i input.png output.jpg -y

# Convert to WebP
cwebp input.jpg -o output.webp

# MP4 to MOV
ffmpeg -i video.mp4 video.mov -y

# MP3 to WAV
ffmpeg -i audio.mp3 audio.wav -y

# Compress PDF
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf
```

**Option B: Using FileConverter CLI**

After building:

```bash
# List available converters
.build/release/fileconverter list

# Convert a file
.build/release/fileconverter convert input.jpg output.png
```

---

### Method 2: Download Pre-Built Executable

*(Coming soon - will be provided in releases)*

---

## 📚 Common Use Cases

### Image Conversion

**Convert single image:**
```bash
ffmpeg -i photo.jpg photo.png -y
```

**Batch convert all JPEGs to PNG:**
```bash
for file in *.jpg; do
    ffmpeg -i "$file" "${file%.jpg}.png" -y
done
```

**Resize while converting:**
```bash
ffmpeg -i input.jpg -vf scale=800:600 output.png -y
```

**Convert with quality setting:**
```bash
ffmpeg -i input.jpg -q:v 2 output.jpg -y
```

### Video Conversion

**MP4 to MOV:**
```bash
ffmpeg -i video.mp4 video.mov -y
```

**Change video quality:**
```bash
ffmpeg -i input.mp4 -c:v libx264 -preset fast output.mp4 -y
```

**Extract audio from video:**
```bash
ffmpeg -i video.mp4 -q:a 0 -map a audio.mp3
```

### Audio Conversion

**MP3 to WAV:**
```bash
ffmpeg -i audio.mp3 audio.wav -y
```

**Change audio quality:**
```bash
ffmpeg -i input.mp3 -q:a 5 output.mp3 -y
```

**Convert with specific bitrate:**
```bash
ffmpeg -i input.wav -b:a 192k output.mp3 -y
```

### PDF Compression

**Compress PDF:**
```bash
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile=compressed.pdf original.pdf
```

**Quality levels:**
- `/screen` - Lowest quality, smallest file
- `/ebook` - Medium quality
- `/printer` - Good quality
- `/prepress` - High quality

---

## 🛠️ For Developers: Contributing to FileConverter

### Prerequisites
- macOS 13.0 or later
- Swift 5.9+
- Xcode Command-Line Tools
- Git

### Local Development Setup

#### 1. Clone and Setup
```bash
git clone https://github.com/Aman-Gupta710/FileConverter.git
cd FileConverter

# Install development dependencies
brew install ffmpeg cwebp exiftool ghostscript
```

#### 2. Project Structure
```
FileConverter/
├── Core/                    # Conversion logic
│   ├── Converter.swift     # Data models
│   ├── ConverterEngine.swift
│   ├── ConfigLoader.swift
│   ├── ProcessManager.swift
│   ├── ToolManager.swift
│   ├── JobQueue.swift
│   └── Resources/converters.yaml
├── CLI/                     # Command-line interface
│   └── main.swift
├── FileConverter/           # GUI (planned)
├── Package.swift
└── README.md
```

#### 3. Build and Test
```bash
# Build release version
swift build -c release

# Run the CLI
.build/release/fileconverter list

# Test a conversion
.build/release/fileconverter convert test.jpg test.png
```

#### 4. Making Changes

**Follow this workflow:**

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Update relevant files
   - Follow Swift conventions
   - Keep commits atomic and descriptive

3. **Test your changes:**
   ```bash
   # Build
   swift build -c release
   
   # Test conversion
   .build/release/fileconverter convert test.jpg test.png
   ```

4. **Commit with clear message:**
   ```bash
   git commit -m "feat(module): description of changes"
   ```

   Commit types:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation
   - `refactor:` Code refactoring
   - `test:` Tests
   - `chore:` Maintenance

5. **Push and create Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Adding New Converters

#### Option 1: Via Configuration (Easiest)

Edit `Core/Resources/converters.yaml`:

```yaml
converters:
  - id: "format-a-to-b"
    name: "Format A → Format B"
    category: "category"
    inputFormats: ["a"]
    outputFormats: ["b"]
    tool: "tool-name"
    command: "tool-name {input} -o {output}"
    options: []
```

#### Option 2: Via Code

Edit `Core/ConverterEngine.swift` to add custom logic.

### Code Style Guidelines

- Use descriptive variable names
- Add comments for complex logic
- Keep functions small and focused
- Use async/await for I/O operations
- Handle errors explicitly

### Testing

```bash
# Run tests (when available)
swift test

# Manual test
.build/release/fileconverter convert sample.jpg sample.png
```

---

## 🐛 Troubleshooting

### Issue: "Command not found: ffmpeg"

**Solution:** Install the tool:
```bash
brew install ffmpeg
```

### Issue: Permission Denied

**Solution:** Make executable:
```bash
chmod +x FileConverter/.build/release/fileconverter
```

### Issue: No output file created

**Solution:** Check input file exists:
```bash
ls -la input.jpg
```

### Issue: CLI shows "No converters found"

**Solution:** Copy config file:
```bash
mkdir -p ~/.fileconverter
cp Core/Resources/converters.yaml ~/.fileconverter/
```

---

## 📋 Feature Roadmap

- [x] Core conversion engine
- [x] CLI tool
- [x] Multi-format support
- [x] Config-based converters
- [ ] GUI application (SwiftUI)
- [ ] Windows support
- [ ] Batch processing UI
- [ ] Drag-and-drop interface
- [ ] Progress tracking
- [ ] Conversion presets

---

## 📖 Documentation

- [README.md](README.md) - Project overview
- [SETUP.md](SETUP.md) - Installation guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [LICENSE](LICENSE) - MIT License

---

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 💬 Getting Help

- **Questions?** Open an issue on GitHub
- **Found a bug?** Report it with reproduction steps
- **Want a feature?** Describe your use case
- **Need help?** Comment on an existing issue

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

**Made with ❤️ for the open source community**

**Last Updated:** October 2026
