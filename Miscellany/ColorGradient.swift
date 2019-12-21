import AppKit
import Foundation

enum ColorGradient {
    static let colors = [
        0xA478E8, 0x9B76E8, 0x9174E8, 0x8872E8, 0x7E70E9, 0x746FE9, 0x6D70E9, 0x6B77EA,
        0x697EEA, 0x6786EA, 0x668EEA, 0x6496EB, 0x629EEB, 0x60A7EB, 0x5EB0EC, 0x5DB9EC,
        0x5BC3EC, 0x59CDEC, 0x57D7ED, 0x55E2ED, 0x53ECED, 0x52EEE3, 0x50EED9, 0x4EEECD,
        0x4CEEC2, 0x4AEFB6, 0x48EFAA, 0x46EF9E, 0x44EF91, 0x43F084, 0x41F077, 0x3FF06A,
        0x3DF15C, 0x3BF14E, 0x39F13F, 0x3EF237, 0x49F235, 0x55F233, 0x61F231, 0x6DF32F,
        0x79F32D, 0x86F32C, 0x93F42A, 0xA0F428, 0xAEF426, 0xBCF424, 0xCAF522, 0xD9F520,
        0xE8F51E, 0xF6F41C, 0xF6E51A, 0xF6D518, 0xF6C616, 0xF7B614, 0xF7A612, 0xF79510,
        0xF8840E, 0xF8730C, 0xF8610A, 0xF84F08, 0xF93D06, 0xF92B04, 0xF91802, 0xF90400
    ].reversed()

    static func getColorIndex(_ numerator: Int, _ denominator: Int) -> Int {
        let percentage = abs(Double(numerator) / Double(denominator))

        let scale = ColorGradient.colors.count
        let constrained = constrain(percentage, lo: 0, hi: 1.0)
        let scaled = Int(constrained * Double(scale))
        let colorSS = min(scaled, scale - 1)
        let index = ColorGradient.colors.index(ColorGradient.colors.startIndex, offsetBy: colorSS)
        let hexRgb = colors[index]

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

    static func makeColorMixRedBlue(
        baseColor: Int, redPercentage: CGFloat, bluePercentage: CGFloat
    ) -> NSColor {
        let redByteWise = min(Int(redPercentage * 256), 255)
        let blueByteWise = min(Int(bluePercentage * 256), 255)

        let hexRGB = baseColor + (redByteWise << 16) + blueByteWise
//        Log.L.write("hexRGB", String(format: "0x%06X", hexRGB))
        return makeColor(hexRGB: hexRGB)
    }
}
