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

extension ArkoniaLayout.SeasonFactorView {
    static let frameWidth: CGFloat = 40

    static let bgFrameWidth: CGFloat = 40
    static var bgFrameHeight = CGFloat.zero // Set by the app startup

    static let annualTrackFrameWidth: CGFloat = 10
    static var annualTrackFrameHeight = CGFloat.zero // Set by the app startup

    static let naturalArrowHeightInAssetCatalog: CGFloat = 100

    static let seasonalArrowFrameWidth: CGFloat = 10
    static let seasonalArrowFrameHeightScale: CGFloat = 200 / naturalArrowHeightInAssetCatalog
    static let seasonalArrowCornerRadius: CGFloat = 5

    static let diurnalArrowFrameWidth: CGFloat = 20
    static let diurnalArrowFrameHeightScale: CGFloat = 50 / naturalArrowHeightInAssetCatalog
}
