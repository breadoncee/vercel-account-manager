// Regenerate assets/demo.gif on macOS: swift scripts/render-readme-demo.swift
import AppKit
import ImageIO
import UniformTypeIdentifiers

let width = 840
let height = 286

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        calibratedRed: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: 1
    )
}

func rect(_ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat, fill: UInt32) {
    color(fill).setFill()
    NSRect(x: x, y: CGFloat(height) - top - h, width: w, height: h).fill()
}

func text(_ value: String, _ x: CGFloat, _ top: CGFloat, size: CGFloat = 17, tint: UInt32 = 0xdce7ee) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .regular),
        .foregroundColor: color(tint)
    ]
    (value as NSString).draw(at: NSPoint(x: x, y: CGFloat(height) - top - size - 5), withAttributes: attrs)
}

func frame(_ active: Int) -> CGImage {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    rect(0, 0, CGFloat(width), CGFloat(height), fill: 0x0f1722)
    rect(0, 0, CGFloat(width), 1, fill: 0x334c5a)
    rect(0, CGFloat(height - 1), CGFloat(width), 1, fill: 0x334c5a)

    let commands = ["vcm use --global personal", "vcm use work acme-team", "vcm status"]
    let outputs = [
        ["Global default account: personal."],
        ["Project config: /app/.vcmrc"],
        ["Account: work", "Team: acme-team     Source: /app/.vcmrc"]
    ]
    for index in 0..<3 {
        let y = CGFloat(19 + index * 88)
        let selected = index == active
        if selected { rect(0, y + 3, 5, 58, fill: 0x64dfc6) }
        text("$", 29, y, tint: selected ? 0x64dfc6 : 0x667c89)
        text(commands[index], 56, y, tint: selected ? 0xffffff : 0xa6bac5)
        for (line, output) in outputs[index].enumerated() {
            text(output, 56, y + 30 + CGFloat(line * 25), size: 15, tint: selected ? 0xbdd0d7 : 0x748a99)
        }
        if index < 2 { rect(29, y + 77, CGFloat(width - 58), 1, fill: 0x263643) }
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
    CGImageDestinationAddImage(destination, frame(step), [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1.8]] as CFDictionary)
}
guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not finish assets/demo.gif")
}
