#!/usr/bin/env python3
"""
FileConverter - Native macOS Desktop Application
A professional file converter with native GUI
"""

import objc
import sys
from AppKit import NSApplication, NSWindow, NSView, NSRect, NSButton, NSTextField, NSComboBox, NSScrollView
from AppKit import NSColor, NSFont, NSTextView, NSPasteboard
from Foundation import NSObject

class FileConverterAppDelegate(NSObject):
    window = objc.IBOutlet()

    def applicationDidFinishLaunching_(self, notification):
        frame = NSRect((0, 0), (800, 600))
        self.window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
            frame,
            15,  # NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
            2,
            False
        )
        self.window.setTitle_("FileConverter")
        self.window.setReleasedWhenClosed_(False)

        content_view = ConverterView.alloc().initWithFrame_(NSRect((0, 0), (800, 600)))
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
        return self

    def setupUI(self):
        self.setBackgroundColor_(NSColor.whiteColor())

        # Title
        title = NSTextField.alloc().initWithFrame_(NSRect((20, 500), (400, 50)))
        title.setStringValue_("🎨 FileConverter")
        title.setFont_(NSFont.systemFontOfSize_(28))
        title.setEditable_(False)
        title.setBezeled_(False)
        title.setDrawsBackground_(False)
        self.addSubview_(title)

        # Subtitle
        subtitle = NSTextField.alloc().initWithFrame_(NSRect((20, 475), (600, 20)))
        subtitle.setStringValue_("Offline file conversion • No limits • No subscriptions")
        subtitle.setFont_(NSFont.systemFontOfSize_(12))
        subtitle.setEditable_(False)
        subtitle.setBezeled_(False)
        subtitle.setDrawsBackground_(False)
        subtitle.setTextColor_(NSColor.grayColor())
        self.addSubview_(subtitle)

        # Format selector label
        format_label = NSTextField.alloc().initWithFrame_(NSRect((20, 430), (200, 20)))
        format_label.setStringValue_("📁 Select Format:")
        format_label.setFont_(NSFont.systemFontOfSize_(13))
        format_label.setEditable_(False)
        format_label.setBezeled_(False)
        format_label.setDrawsBackground_(False)
        self.addSubview_(format_label)

        # Format dropdown
        self.format_combo = NSComboBox.alloc().initWithFrame_(NSRect((20, 400), (300, 25)))
        self.format_combo.addItemsWithObjectValues_([
            "Images (JPG, PNG, WebP)",
            "Video (MP4, MOV)",
            "Audio (MP3, WAV)",
            "PDF Compression"
        ])
        self.format_combo.setEditable_(False)
        self.addSubview_(self.format_combo)

        # Input file label
        input_label = NSTextField.alloc().initWithFrame_(NSRect((20, 365), (200, 20)))
        input_label.setStringValue_("📂 Input File:")
        input_label.setFont_(NSFont.systemFontOfSize_(13))
        input_label.setEditable_(False)
        input_label.setBezeled_(False)
        input_label.setDrawsBackground_(False)
        self.addSubview_(input_label)

        # Input file field
        self.input_field = NSTextField.alloc().initWithFrame_(NSRect((20, 335), (350, 25)))
        self.input_field.setPlaceholderString_("/Users/username/photo.jpg")
        self.input_field.setBezeled_(True)
        self.input_field.setDrawsBackground_(True)
        self.addSubview_(self.input_field)

        # Output file label
        output_label = NSTextField.alloc().initWithFrame_(NSRect((20, 300), (200, 20)))
        output_label.setStringValue_("💾 Output File:")
        output_label.setFont_(NSFont.systemFontOfSize_(13))
        output_label.setEditable_(False)
        output_label.setBezeled_(False)
        output_label.setDrawsBackground_(False)
        self.addSubview_(output_label)

        # Output file field
        self.output_field = NSTextField.alloc().initWithFrame_(NSRect((20, 270), (350, 25)))
        self.output_field.setPlaceholderString_("/Users/username/photo.png")
        self.output_field.setBezeled_(True)
        self.output_field.setDrawsBackground_(True)
        self.addSubview_(self.output_field)

        # Generate button
        generate_btn = NSButton.alloc().initWithFrame_(NSRect((20, 220), (170, 35)))
        generate_btn.setTitle_("✨ Generate Command")
        generate_btn.setBezelStyle_(0)
        generate_btn.setTarget_(self)
        generate_btn.setAction_("generateCommand:")
        self.addSubview_(generate_btn)

        # Copy button
        copy_btn = NSButton.alloc().initWithFrame_(NSRect((200, 220), (170, 35)))
        copy_btn.setTitle_("📋 Copy to Clipboard")
        copy_btn.setBezelStyle_(0)
        copy_btn.setTarget_(self)
        copy_btn.setAction_("copyCommand:")
        self.addSubview_(copy_btn)

        # Command display label
        cmd_label = NSTextField.alloc().initWithFrame_(NSRect((20, 185), (200, 20)))
        cmd_label.setStringValue_("🖥️ Terminal Command:")
        cmd_label.setFont_(NSFont.systemFontOfSize_(13))
        cmd_label.setEditable_(False)
        cmd_label.setBezeled_(False)
        cmd_label.setDrawsBackground_(False)
        self.addSubview_(cmd_label)

        # Command text view
        self.command_view = NSTextView.alloc().initWithFrame_(NSRect((20, 50), (760, 130)))
        self.command_view.setString_("Select format and enter file paths above...")
        self.command_view.setFont_(NSFont.userFixedPitchFontOfSize_(11))
        self.command_view.setEditable_(True)
        self.command_view.setSelectable_(True)
        self.command_view.setBackgroundColor_(NSColor.colorWithRed_green_blue_alpha_(0.95, 0.95, 0.95, 1.0))
        self.addSubview_(self.command_view)

        # Footer
        footer = NSTextField.alloc().initWithFrame_(NSRect((20, 15), (760, 20)))
        footer.setStringValue_("💡 Copy the command and paste it in Terminal to convert your file")
        footer.setFont_(NSFont.systemFontOfSize_(11))
        footer.setEditable_(False)
        footer.setBezeled_(False)
        footer.setDrawsBackground_(False)
        footer.setTextColor_(NSColor.grayColor())
        self.addSubview_(footer)

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

def main():
    app = NSApplication.sharedApplication()
    delegate = FileConverterAppDelegate.alloc().init()
    app.setDelegate_(delegate)
    app.run()

if __name__ == '__main__':
    main()
