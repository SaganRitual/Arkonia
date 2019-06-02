import AppKit
import Foundation

enum ColorGradient {
    static let colors = [
        0x8257FF, 0x7656FE, 0x6A55FD, 0x5E54FC, 0x5354FB, 0x525FFA, 0x5169F9, 0x5174F8,
        0x507EF7, 0x4F88F6, 0x4E93F5, 0x4D9DF4, 0x4DA7F3, 0x4CB2F2, 0x4BBCF1, 0x4AC6F0,
        0x49D0EF, 0x49DBEE, 0x48E5ED, 0x47ECE9, 0x46EBDD, 0x45EAD1, 0x45E9C5, 0x44E8B9,
        0x43E7AD, 0x42E6A1, 0x42E595, 0x41E489, 0x40E37E, 0x3FE272, 0x3FE166, 0x3EE05A,
        0x3DE04F, 0x3CDF43, 0x40DE3C, 0x4ADD3B, 0x54DC3A, 0x5FDB3A, 0x69DA39, 0x73D938,
        0x7DD837, 0x87D737, 0x91D636, 0x9AD535, 0xA4D435, 0xAED334, 0xB8D233, 0xC2D133,
        0xCBD032, 0xCFC931, 0xCEBE31, 0xCDB230, 0xCCA72F, 0xCB9B2F, 0xCA902E, 0xC9842D,
        0xC8792D, 0xC76E2C, 0xC6632C, 0xC5582B, 0xC44C2A, 0xC3412A, 0xC23629, 0xC22C29
    ].reversed()

    static func getColorIndex(_ numerator: Int, _ denominator: Int) -> Int {
        let percentage = abs(Double(numerator) / Double(denominator))

        let scale = ColorGradient.colors.count
        let constrained = constrain(percentage, lo: 0, hi: 1.0)
        let scaled = Int(constrained * Double(scale))
        let colorSS = min(scaled, scale - 1)
        let index = ColorGradient.colors.index(ColorGradient.colors.startIndex, offsetBy: colorSS)
        let hexRgb = colors.distance(from: colors.startIndex, to: index)

        return hexRgb
    }

    static func makeColor(_ numerator: Int, _ denominator: Int) -> NSColor {
        let hexRGB = getColorIndex(numerator, denominator)
        let nsColor = makeColor(hexRGB: hexRGB)
        return nsColor
    }

    static func makeColor(hexRGB: Int) -> NSColor {
        let r = Double((hexRGB >> 16) & 0xFF) / 256
        let g = Double((hexRGB >>  8) & 0xFF) / 256
        let b = Double(hexRGB         & 0xFF) / 256

        return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g),
                       blue: CGFloat(b), alpha: CGFloat(1.0))
    }
}
