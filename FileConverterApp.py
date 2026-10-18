#!/usr/bin/env python3
"""
FileConverter - Native macOS Desktop Application
A professional file converter with native GUI and drag-and-drop support
"""

import objc
import sys
import subprocess
import os
from AppKit import NSApplication, NSWindow, NSView, NSRect, NSButton, NSTextField, NSComboBox, NSScrollView
from AppKit import NSColor, NSFont, NSTextView, NSPasteboard, NSDragOperationCopy, NSPasteboardTypeFileURL
from AppKit import NSStringPboardType
from Foundation import NSObject, NSURL

class FileConverterAppDelegate(NSObject):
    window = objc.IBOutlet()

    def applicationDidFinishLaunching_(self, notification):
        frame = NSRect((0, 0), (900, 650))
        self.window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
            frame,
            15,
            2,
            False
        )
        self.window.setTitle_("FileConverter - Drag files to convert")
        self.window.setReleasedWhenClosed_(False)

        content_view = ConverterView.alloc().initWithFrame_(NSRect((0, 0), (900, 650)))
        self.window.setContentView_(content_view)
        self.window.center()
        self.window.makeKeyAndOrderFront_(None)

    def applicationShouldTerminateAfterLastWindowClosed_(self, app):
        return True

class ConverterView(NSView):
    def initWithFrame_(self, frame):
        self = objc.super(ConverterView, self).initWithFrame_(frame)
        if self:
            self.setupUI()
            self.registerForDraggedTypes_([NSPasteboardTypeFileURL])
        return self

    def setupUI(self):
        self.setBackgroundColor_(NSColor.colorWithRed_green_blue_alpha_(0.95, 0.95, 0.98, 1.0))

        # Title
        title = NSTextField.alloc().initWithFrame_(NSRect((20, 580), (500, 50)))
        title.setStringValue_("🎨 FileConverter")
        title.setFont_(NSFont.systemFontOfSize_(32))
        title.setEditable_(False)
        title.setBezeled_(False)
        title.setDrawsBackground_(False)
        self.addSubview_(title)

        # Subtitle
        subtitle = NSTextField.alloc().initWithFrame_(NSRect((20, 555), (800, 20)))
        subtitle.setStringValue_("Drag files here to convert • Or use the controls below")
        subtitle.setFont_(NSFont.systemFontOfSize_(13))
        subtitle.setEditable_(False)
        subtitle.setBezeled_(False)
        subtitle.setDrawsBackground_(False)
        subtitle.setTextColor_(NSColor.grayColor())
        self.addSubview_(subtitle)

        # Drag & Drop Zone
        drag_zone = NSView.alloc().initWithFrame_(NSRect((20, 400), (860, 120)))
        drag_zone.setBackgroundColor_(NSColor.colorWithRed_green_blue_alpha_(0.85, 0.92, 1.0, 0.3))
        drag_zone.setWantsLayer_(True)
        drag_zone.layer().setCornerRadius_(12)
        drag_zone.layer().setBorderWidth_(2)
        drag_zone.layer().setBorderColor_(NSColor.colorWithRed_green_blue_alpha_(0.3, 0.6, 1.0, 0.6).CGColor())
        self.addSubview_(drag_zone)

        # Drag & Drop text
        drag_text = NSTextField.alloc().initWithFrame_(NSRect((40, 440), (820, 60)))
        drag_text.setStringValue_("📁 Drag & Drop Files Here\n\nJPG, PNG, WebP • MP4, MOV • MP3, WAV • PDF")
        drag_text.setFont_(NSFont.systemFontOfSize_(16))
        drag_text.setEditable_(False)
        drag_text.setBezeled_(False)
        drag_text.setDrawsBackground_(False)
        drag_text.setAlignment_(1)  # Center alignment
        self.addSubview_(drag_text)

        # Format selector label
        format_label = NSTextField.alloc().initWithFrame_(NSRect((20, 360), (200, 20)))
        format_label.setStringValue_("📁 Select Format:")
        format_label.setFont_(NSFont.systemFontOfSize_(13))
        format_label.setEditable_(False)
        format_label.setBezeled_(False)
        format_label.setDrawsBackground_(False)
        self.addSubview_(format_label)

        # Format dropdown
        self.format_combo = NSComboBox.alloc().initWithFrame_(NSRect((20, 330), (300, 25)))
        self.format_combo.addItemsWithObjectValues_([
            "Images (JPG, PNG, WebP)",
            "Video (MP4, MOV)",
            "Audio (MP3, WAV)",
            "PDF Compression"
        ])
        self.format_combo.setEditable_(False)
        self.addSubview_(self.format_combo)

        # Input file label
        input_label = NSTextField.alloc().initWithFrame_(NSRect((20, 295), (200, 20)))
        input_label.setStringValue_("📂 Input File:")
        input_label.setFont_(NSFont.systemFontOfSize_(13))
        input_label.setEditable_(False)
        input_label.setBezeled_(False)
        input_label.setDrawsBackground_(False)
        self.addSubview_(input_label)

        # Input file field
        self.input_field = NSTextField.alloc().initWithFrame_(NSRect((20, 265), (410, 25)))
        self.input_field.setPlaceholderString_("/Users/username/photo.jpg")
        self.input_field.setBezeled_(True)
        self.input_field.setDrawsBackground_(True)
        self.addSubview_(self.input_field)

        # Output file label
        output_label = NSTextField.alloc().initWithFrame_(NSRect((470, 295), (200, 20)))
        output_label.setStringValue_("💾 Output File:")
        output_label.setFont_(NSFont.systemFontOfSize_(13))
        output_label.setEditable_(False)
        output_label.setBezeled_(False)
        output_label.setDrawsBackground_(False)
        self.addSubview_(output_label)

        # Output file field
        self.output_field = NSTextField.alloc().initWithFrame_(NSRect((470, 265), (410, 25)))
        self.output_field.setPlaceholderString_("/Users/username/photo.png")
        self.output_field.setBezeled_(True)
        self.output_field.setDrawsBackground_(True)
        self.addSubview_(self.output_field)

        # Generate button
        generate_btn = NSButton.alloc().initWithFrame_(NSRect((20, 215), (190, 35)))
        generate_btn.setTitle_("✨ Generate Command")
        generate_btn.setBezelStyle_(0)
        generate_btn.setTarget_(self)
        generate_btn.setAction_("generateCommand:")
        self.addSubview_(generate_btn)

        # Copy button
        copy_btn = NSButton.alloc().initWithFrame_(NSRect((220, 215), (190, 35)))
        copy_btn.setTitle_("📋 Copy to Clipboard")
        copy_btn.setBezelStyle_(0)
        copy_btn.setTarget_(self)
        copy_btn.setAction_("copyCommand:")
        self.addSubview_(copy_btn)

        # Convert button (new)
        convert_btn = NSButton.alloc().initWithFrame_(NSRect((420, 215), (190, 35)))
        convert_btn.setTitle_("🚀 Convert Now")
        convert_btn.setBezelStyle_(0)
        convert_btn.setTarget_(self)
        convert_btn.setAction_("convertNow:")
        self.addSubview_(convert_btn)

        # Open output button (new)
        open_btn = NSButton.alloc().initWithFrame_(NSRect((620, 215), (250, 35)))
        open_btn.setTitle_("📂 Open Output Folder")
        open_btn.setBezelStyle_(0)
        open_btn.setTarget_(self)
        open_btn.setAction_("openOutputFolder:")
        self.addSubview_(open_btn)

        # Command display label
        cmd_label = NSTextField.alloc().initWithFrame_(NSRect((20, 175), (200, 20)))
        cmd_label.setStringValue_("🖥️ Terminal Command:")
        cmd_label.setFont_(NSFont.systemFontOfSize_(13))
        cmd_label.setEditable_(False)
        cmd_label.setBezeled_(False)
        cmd_label.setDrawsBackground_(False)
        self.addSubview_(cmd_label)

        # Command text view
        self.command_view = NSTextView.alloc().initWithFrame_(NSRect((20, 30), (860, 140)))
        self.command_view.setString_("Drag files here or select format and enter paths above...")
        self.command_view.setFont_(NSFont.userFixedPitchFontOfSize_(11))
        self.command_view.setEditable_(True)
        self.command_view.setSelectable_(True)
        self.command_view.setBackgroundColor_(NSColor.colorWithRed_green_blue_alpha_(0.95, 0.95, 0.95, 1.0))
        self.addSubview_(self.command_view)

    def generateCommand_(self, sender):
        format_idx = self.format_combo.indexOfSelectedItem()
        input_file = self.input_field.stringValue()
        output_file = self.output_field.stringValue()

        if format_idx < 0 or not input_file or not output_file:
            self.command_view.setString_("⚠️ Please select format and enter file paths")
            return

        formats = [
            ("image", "ffmpeg"),
            ("video", "ffmpeg"),
            ("audio", "ffmpeg"),
            ("pdf", "gs")
        ]

        format_type, tool = formats[format_idx]

        if format_type == "pdf":
            cmd = f'gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="{output_file}" "{input_file}"'
        elif format_type == "image" and output_file.endswith('.webp'):
            cmd = f'cwebp "{input_file}" -o "{output_file}"'
        else:
            cmd = f'ffmpeg -i "{input_file}" "{output_file}" -y'

        self.command_view.setString_(cmd)

    def copyCommand_(self, sender):
        cmd = self.command_view.string()
        if "Please select" in cmd or "Select format" in cmd:
            return

        pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.setString_forType_(cmd, "public.utf8-plain-text")
        self.command_view.setString_(f"{cmd}\n\n✅ Copied! Paste in Terminal.")

    def convertNow_(self, sender):
        cmd = self.command_view.string()
        if "Please select" in cmd or "Select format" in cmd or "Copied" in cmd or "Drag files" in cmd:
            return

        try:
            subprocess.run(cmd, shell=True, check=True)
            output_file = self.output_field.stringValue()
            self.command_view.setString_(f"{cmd}\n\n✅ Conversion complete! File saved to:\n{output_file}")
        except Exception as e:
            self.command_view.setString_(f"{cmd}\n\n❌ Error: {str(e)}")

    def openOutputFolder_(self, sender):
        output_file = self.output_field.stringValue()
        if not output_file:
            return

        folder = os.path.dirname(output_file)
        if os.path.exists(folder):
            subprocess.run(['open', folder])

    # Drag and Drop support
    def draggingEntered_(self, sender):
        return NSDragOperationCopy

    def draggingUpdated_(self, sender):
        return NSDragOperationCopy

    def draggingExited_(self, sender):
        pass

    def performDragOperation_(self, sender):
        pasteboard = sender.draggingPasteboard()
        files = pasteboard.propertyListForType_(NSPasteboardTypeFileURL)

        if files:
            file_path = files[0]
            if isinstance(file_path, str):
                file_path = file_path.replace('file://', '')

            # Auto-detect format from file extension
            ext = os.path.splitext(file_path)[1].lower()

            self.input_field.setStringValue_(file_path)

            # Auto-select format
            if ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']:
                self.format_combo.selectItemAtIndex_(0)
            elif ext in ['.mp4', '.mov', '.avi', '.mkv']:
                self.format_combo.selectItemAtIndex_(1)
            elif ext in ['.mp3', '.wav', '.aac', '.flac']:
                self.format_combo.selectItemAtIndex_(2)
            elif ext == '.pdf':
                self.format_combo.selectItemAtIndex_(3)

            # Generate output filename
            base_name = os.path.splitext(file_path)[0]
            folder = os.path.dirname(file_path)

            if ext in ['.jpg', '.jpeg', '.png', '.gif', '.bmp'] and ext != '.png':
                output_path = f"{base_name}.png"
            elif ext == '.png':
                output_path = f"{base_name}.jpg"
            elif ext in ['.mp4', '.avi', '.mkv']:
                output_path = f"{base_name}.mov"
            elif ext == '.mp3':
                output_path = f"{base_name}.wav"
            elif ext == '.wav':
                output_path = f"{base_name}.mp3"
            elif ext == '.pdf':
                output_path = f"{base_name}_compressed.pdf"
            else:
                output_path = f"{base_name}_converted"

            self.output_field.setStringValue_(output_path)
            self.generateCommand_(None)

            return True

        return False

def main():
    app = NSApplication.sharedApplication()
    delegate = FileConverterAppDelegate.alloc().init()
    app.setDelegate_(delegate)
    app.run()

if __name__ == '__main__':
    main()
