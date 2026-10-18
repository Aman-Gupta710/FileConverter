# FileConverter - Key Features

## 🎯 Easy Conversion Methods

### Method 1: Drag-and-Drop (Like Tangerine!)
1. **Open** FileConverter app
2. **Drag any file** into the drag zone
3. App **auto-detects format**
4. App **auto-generates output filename**
5. Click **🚀 Convert Now** button
✨ Done!

### Method 2: Manual Selection
1. Select format from dropdown
2. Enter input file path
3. Enter output file path
4. Click **Generate Command**
5. Click **Convert Now** or **Copy to Clipboard**

### Method 3: Quick Action (Right-Click)
1. Right-click any file in Finder
2. Select "FileConverter Quick Action"
3. App opens with file ready
4. Select conversion format
5. Click Convert

### Method 4: CLI (Command Line)
```bash
ffmpeg -i input.jpg output.png -y
ffmpeg -i input.mp4 output.mov -y
ffmpeg -i input.mp3 output.wav -y
cwebp input.jpg -o output.webp
gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=output.pdf input.pdf
```

## ✨ Smart Features

✅ **Auto-Format Detection**
- Automatically identifies file type when dragging
- Suggests best output format
- JPG → PNG, PNG → JPG, Image → WebP
- MP4 → MOV, MOV → MP4
- MP3 → WAV, WAV → MP3
- PDF → Compressed PDF

✅ **Auto-Output Naming**
- Generates output filename automatically
- Puts file in same folder as input
- Keeps same name, changes extension
- PDF compression adds "_compressed"

✅ **One-Click Conversion**
- 🚀 Convert Now button for instant conversion
- No need to copy/paste commands
- No Terminal knowledge required

✅ **Output Folder Quick Access**
- 📂 Open Output Folder button
- Instantly opens folder with converted file
- See results immediately

## 📊 Supported Formats

| Type | Conversions |
|------|-------------|
| 🖼️ Images | JPG ↔ PNG, Image → WebP |
| 🎬 Video | MP4 ↔ MOV, AVI → MP4 |
| 🎵 Audio | MP3 ↔ WAV, AAC → MP3 |
| 📄 PDF | Compress with Ghostscript |

## 🎨 User Interface

- **Drag & Drop Zone** - Large visual area for file dropping
- **Format Selector** - Easy dropdown menu
- **Auto-Path Filling** - Paths fill automatically
- **Command Preview** - See the exact command
- **One-Button Conversion** - Click to convert
- **Progress Feedback** - See success/error messages

## 🖥️ Terminal Integration

All features work with Terminal:
```bash
# Copy command to clipboard
# Paste and run in Terminal
ffmpeg -i "/Users/aman/photo.jpg" "/Users/aman/photo.png" -y
```

## 📁 How to Use

### Fast Conversion
1. **Drag file** → App auto-detects → Click **Convert Now** ✨
2. **Done in 2 clicks!**

### Precise Control
1. Select format
2. Enter input/output paths
3. Click **Generate Command**
4. Review command
5. Click **Convert Now** or copy for Terminal

### Folder Integration
1. Right-click file in Finder
2. Select "FileConverter Quick Action"
3. App opens ready to convert

---

**Version:** 1.0  
**License:** MIT (Open Source)  
**Made with ❤️ for macOS**
