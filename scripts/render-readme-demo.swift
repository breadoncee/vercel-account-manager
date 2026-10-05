// Regenerate assets/demo.gif with: swift scripts/render-readme-demo.swift
// Uses macOS AppKit and ImageIO; the generated GIF displays on GitHub and npm.
import AppKit
import ImageIO
import UniformTypeIdentifiers

let width = 960
let height = 450

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: 1
    )
}

func rect(_ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat, radius: CGFloat = 0, fill: UInt32, stroke: UInt32? = nil) {
    let path = NSBezierPath(roundedRect: NSRect(x: x, y: CGFloat(height) - top - h, width: w, height: h), xRadius: radius, yRadius: radius)
    color(fill).setFill()
    path.fill()
    if let stroke {
        color(stroke).setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}

func text(_ value: String, _ x: CGFloat, _ top: CGFloat, size: CGFloat = 18, tint: UInt32 = 0xe7eef7, bold: Bool = false) {
    let font = bold ? NSFont.monospacedSystemFont(ofSize: size, weight: .semibold) : NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color(tint)]
    (value as NSString).draw(at: NSPoint(x: x, y: CGFloat(height) - top - size - 5), withAttributes: attrs)
}

func frame(_ step: Int) -> CGImage {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    rect(0, 0, CGFloat(width), CGFloat(height), fill: 0x0b1220)
    rect(0, 0, CGFloat(width), 57, fill: 0x142033)
    for (index, shade) in [0xff6b76, 0xf5c45f, 0x5dd9b2].enumerated() {
        rect(CGFloat(26 + index * 22), 22, 11, 11, radius: 6, fill: UInt32(shade))
    }
    text("vcm", 107, 15, size: 22, tint: 0xffffff, bold: true)
    text("/ project routing", 169, 18, size: 17, tint: 0x96a9bf)

    rect(26, 79, 237, 341, radius: 18, fill: 0x111d2e, stroke: 0x2c4259)
    text("ACCOUNTS", 47, 103, size: 14, tint: 0x93a9bf, bold: true)
    for (index, name) in ["personal", "work"].enumerated() {
        let selected = index == (step == 0 ? 0 : 1)
        let y = CGFloat(143 + index * 61)
        rect(42, y, 205, 48, radius: 10, fill: selected ? 0x1b3d43 : 0x172539, stroke: selected ? 0x35c7ad : nil)
        rect(57, y + 16, 16, 16, radius: 8, fill: selected ? 0x4cdbc2 : 0x657f99)
        text(name, 87, y + 10, size: 17, tint: selected ? 0xf3fffb : 0xb2c0cf, bold: selected)
    }
    text("GLOBAL DEFAULT", 47, 296, size: 13, tint: 0x7e96ae, bold: true)
    text("personal", 47, 320, size: 17, tint: 0xd5e0ed)

    rect(280, 79, 654, 341, radius: 18, fill: 0x111d2e, stroke: 0x2c4259)
    text(step == 0 ? "01 / SET A DEFAULT" : step == 1 ? "02 / PIN THIS PROJECT" : "03 / CHECK THE RESULT", 307, 103, size: 14, tint: 0x62dfc6, bold: true)
    rect(307, 142, 600, 1, fill: 0x2d4156)
    let command = step == 0 ? "vcm use --global personal" : step == 1 ? "vcm use work acme-team" : "vcm status"
    text("$", 307, 168, size: 20, tint: 0x64ddc4, bold: true)
    text(command, 336, 168, size: 20, tint: 0xf3f7fc, bold: true)
    if step == 0 {
        text("Global default account: personal.", 307, 224, size: 18, tint: 0xc2d2e2)
        text("Used whenever a project has no .vcmrc", 307, 283, size: 16, tint: 0x849db5)
    } else if step == 1 {
        text("Project config: /app/.vcmrc", 307, 224, size: 18, tint: 0xc2d2e2)
        text("account=work    team=acme-team", 307, 283, size: 16, tint: 0x849db5)
    } else {
        text("Account: work", 307, 224, size: 18, tint: 0xc2d2e2)
        text("Team: acme-team", 307, 258, size: 18, tint: 0xc2d2e2)
        text("Source: /app/.vcmrc", 307, 292, size: 18, tint: 0xc2d2e2)
    }
    for index in 0..<3 {
        rect(CGFloat(540 + index * 25), 378, 15, 6, radius: 3, fill: index == step ? 0x54d7bf : 0x3d5368)
    }
    NSGraphicsContext.current?.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return rep.cgImage!
}

let url = URL(fileURLWithPath: "assets/demo.gif")
guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, 3, nil) else {
    fatalError("Could not create assets/demo.gif")
}
CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
for step in 0..<3 {
    CGImageDestinationAddImage(destination, frame(step), [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 2.2]] as CFDictionary)
}
guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not finish assets/demo.gif")
}
