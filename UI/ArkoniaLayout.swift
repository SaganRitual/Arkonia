import CoreGraphics
import SwiftUI

enum ArkoniaLayout {
    enum AlmanacView {}
    enum ButtonsView {}
    enum ContentView {}
    enum DaylightFactorView {}
    enum SeasonFactorView {}
}

extension ArkoniaLayout {
    static let labelFont = Font.system(
        size: ArkoniaLayout.AlmanacView.labelFontSize,
        design: Font.Design.monospaced
    ).lowercaseSmallCaps()

    static let meterFont = Font.system(
        size: ArkoniaLayout.AlmanacView.meterFontSize,
        design: Font.Design.monospaced
    )
}

extension ArkoniaLayout.AlmanacView {
    static let frameWidth: CGFloat = 185
    static let labelFontSize: CGFloat = 12
    static let meterFontSize: CGFloat = 10
}

extension ArkoniaLayout.ButtonsView {
    static let buttonLabelsFrameMinWidth: CGFloat = 45
}

extension ArkoniaLayout.ContentView {
    static let hudHeight: CGFloat = 100
}

extension ArkoniaLayout.DaylightFactorView {
    static let sunstickFrameWidth: CGFloat = 10
    static let sunstickFrameHeight: CGFloat = 100
    static let sunstickCornerRadius: CGFloat = 5

    static let sunFrameWidth: CGFloat = 20
    static let sunFrameHeight: CGFloat = 20
}

extension ArkoniaLayout.SeasonFactorView {
    static let frameWidth: CGFloat = 40

    static let bgFrameWidth: CGFloat = 40
    static var bgFrameHeight = CGFloat.zero // Set by the app startup

    static let stickGrooveFrameWidth: CGFloat = 10
    static var stickGrooveFrameHeight = CGFloat.zero // Set by the app startup

    static let tempIndicatorFrameWidth = bgFrameWidth
    static let tempIndicatorFrameHeight: CGFloat = 3
}
