#!/usr/bin/env python3
"""
FileConverter - Tangerine-style with Wheel Menu
"""

import objc
import sys
import subprocess
import os
import math
from AppKit import (
    NSApplication, NSWindow, NSView, NSRect, NSButton, NSTextField,
    NSColor, NSFont, NSMenu, NSMenuItem,
    NSPasteboard, NSPasteboardTypeFileURL, NSDragOperationCopy
)
from Foundation import NSObject

class FileConverterAppDelegate(NSObject):
    def applicationDidFinishLaunching_(self, notification):
        frame = NSRect((100, 100), (400, 450))
        self.window = NSWindow.alloc().initWithContentRect_styleMask_backing_defer_(
            frame, 15, 2, False
        )
        self.window.setTitle_("FileConverter - Drag & Drop to Convert")
        self.window.setReleasedWhenClosed_(False)

        self.view = ConversionWheelView.alloc().initWithFrame_(NSRect((0, 0), (400, 450)))
        self.window.setContentView_(self.view)
        self.window.center()
        self.window.makeKeyAndOrderFront_(None)

    def applicationShouldTerminateAfterLastWindowClosed_(self, app):
        return False

class ConversionWheelView(NSView):
    def initWithFrame_(self, frame):
        self = objc.super(ConversionWheelView, self).initWithFrame_(frame)
        if self:
            self.selected_file = None
            self.setupUI()
            self.registerForDraggedTypes_([NSPasteboardTypeFileURL])
        return self

    def setupUI(self):
        self.setBackgroundColor_(NSColor.colorWithRed_green_blue_alpha_(0.1, 0.1, 0.1, 0.95))

        # Title
        title = NSTextField.alloc().initWithFrame_(NSRect((20, 400), (360, 35)))
        title.setStringValue_("🎨 FileConverter")
        title.setFont_(NSFont.systemFontOfSize_(28))
        title.setEditable_(False)
        title.setBezeled_(False)
        title.setDrawsBackground_(False)
        title.setTextColor_(NSColor.whiteColor())
        self.addSubview_(title)

        # Instructions
        instructions = NSTextField.alloc().initWithFrame_(NSRect((20, 360), (360, 35)))
        instructions.setStringValue_("Drag file here • Click format to convert")
        instructions.setFont_(NSFont.systemFontOfSize_(12))
        instructions.setEditable_(False)
        instructions.setBezeled_(False)
        instructions.setDrawsBackground_(False)
        instructions.setTextColor_(NSColor.lightGrayColor())
        self.addSubview_(instructions)

        # Wheel button positions
        wheel_center_x = 200
        wheel_center_y = 150
        wheel_radius = 80

        formats = [
            ("📷\nImages", 0),
            ("🎬\nVideo", 72),
            ("🎵\nAudio", 144),
            ("📄\nPDF", 216),
            ("↩️\nMore", 288),
        ]

        self.buttons = {}

        for idx, (label, angle_deg) in enumerate(formats):
            angle_rad = math.radians(angle_deg)
            x = wheel_center_x + wheel_radius * math.cos(angle_rad) - 40
            y = wheel_center_y + wheel_radius * math.sin(angle_rad) - 40

            btn = NSButton.alloc().initWithFrame_(NSRect((x, y), (80, 80)))
            btn.setTitle_(label)
            btn.setFont_(NSFont.systemFontOfSize_(11))
            btn.setBezelStyle_(1)
            btn.setTag_(idx)
            btn.setTarget_(self)
            btn.setAction_("buttonClicked:")
            self.addSubview_(btn)
            self.buttons[idx] = (btn, label.split('\n')[1])

        # File display
        self.file_label = NSTextField.alloc().initWithFrame_(NSRect((20, 40), (360, 80)))
        self.file_label.setStringValue_("📁 Drag file here\nto convert")
        self.file_label.setFont_(NSFont.systemFontOfSize_(12))
        self.file_label.setEditable_(False)
        self.file_label.setBezeled_(True)
        self.file_label.setDrawsBackground_(True)
        self.file_label.setTextColor_(NSColor.whiteColor())
        self.addSubview_(self.file_label)

    def buttonClicked_(self, sender):
        if not self.selected_file:
            self.file_label.setStringValue_("❌ No file!\nDrag first.")
            return

        tag = sender.tag()
        formats = {
            0: ("image", ["jpg", "jpeg"], "png"),
            1: ("video", ["mp4"], "mov"),
            2: ("audio", ["mp3"], "wav"),
            3: ("pdf", ["pdf"], "pdf_compressed"),
            4: ("more", [], ""),
        }

        if tag not in formats:
            return

        format_type, inputs, output_ext = formats[tag]
        self.do_conversion(format_type)

    def do_conversion(self, format_type):
        file_path = self.selected_file
        ext = os.path.splitext(file_path)[1].lower()[1:]
        base = os.path.splitext(file_path)[0]
        folder = os.path.dirname(file_path)

        if format_type == "image":
            output = f"{base}.png" if ext != "png" else f"{base}.jpg"
            cmd = f'ffmpeg -i "{file_path}" "{output}" -y'
        elif format_type == "video":
            output = f"{base}.mov" if ext == "mp4" else f"{base}.mp4"
            cmd = f'ffmpeg -i "{file_path}" "{output}" -y'
        elif format_type == "audio":
            output = f"{base}.wav" if ext == "mp3" else f"{base}.mp3"
            cmd = f'ffmpeg -i "{file_path}" "{output}" -y'
        elif format_type == "pdf":
            output = f"{base}_compressed.pdf"
            cmd = f'gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="{output}" "{file_path}"'
        else:
            return

        try:
            subprocess.run(cmd, shell=True, check=True)
            self.file_label.setStringValue_(f"✅ Done!\n{os.path.basename(output)}")
            subprocess.run(['open', folder])
        except Exception as e:
            self.file_label.setStringValue_(f"❌ Error\n{str(e)[:50]}")

    def draggingEntered_(self, sender):
        return NSDragOperationCopy

    def performDragOperation_(self, sender):
        pb = sender.draggingPasteboard()
        files = pb.propertyListForType_(NSPasteboardTypeFileURL)

        if files:
            path = files[0]
            if isinstance(path, str):
                path = path.replace('file://', '')
            self.selected_file = path
            self.file_label.setStringValue_(f"📁 {os.path.basename(path)}\n\nClick format to convert")
            return True
        return False

def main():
    app = NSApplication.sharedApplication()
    delegate = FileConverterAppDelegate.alloc().init()
    app.setDelegate_(delegate)
    app.run()

if __name__ == '__main__':
    main()
