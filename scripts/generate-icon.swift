import AppKit

// Render the system emoji directly, keeping the logo faithful to 🪫.
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        let context = NSGraphicsContext(bitmapImageRep: bitmap)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        let side = CGFloat(pixels)
        let text = NSAttributedString(string: "🪫", attributes: [
            .font: NSFont(name: "AppleColorEmoji", size: side * 0.78)!
        ])
        let bounds = text.size()
        text.draw(at: NSPoint(x: (side - bounds.width) / 2, y: (side - bounds.height) / 2))
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        let file = output.appendingPathComponent("icon_\(size)x\(size)\(suffix).png")
        try bitmap.representation(using: .png, properties: [:])!.write(to: file)
    }
}

// ICNS supports PNG chunks directly; this also works without iconutil's
// graphical image-conversion services in headless build environments.
func lengthBytes(_ count: Int) -> Data {
    var value = UInt32(count).bigEndian
    return withUnsafeBytes(of: &value) { Data($0) }
}

let entries = [
    ("icp4", "icon_16x16.png"), ("icp5", "icon_32x32.png"),
    ("icp6", "icon_32x32@2x.png"), ("ic07", "icon_128x128.png"),
    ("ic08", "icon_256x256.png"), ("ic09", "icon_512x512.png"),
    ("ic10", "icon_512x512@2x.png"), ("ic11", "icon_16x16@2x.png"),
    ("ic12", "icon_32x32@2x.png"), ("ic13", "icon_128x128@2x.png"),
    ("ic14", "icon_256x256@2x.png")
]
var chunks = Data()
for (type, filename) in entries {
    let png = try Data(contentsOf: output.appendingPathComponent(filename))
    chunks.append(Data(type.utf8))
    chunks.append(lengthBytes(png.count + 8))
    chunks.append(png)
}
var icon = Data("icns".utf8)
icon.append(lengthBytes(chunks.count + 8))
icon.append(chunks)
try icon.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
