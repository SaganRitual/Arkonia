import CoreGraphics
import SwiftUI

enum ArkoniaLayout {
    enum AlmanacView {}
    enum ButtonsView {}
    enum ContentView {}
    enum DaylightFactorView {}
    enum LineChartView {}
    enum SeasonFactorView {}
}

extension ArkoniaLayout {
    static let chartAxisLabelFontSize = CGFloat(10)
    static let labelFontSize = CGFloat(10)
    static let meterFontSize = CGFloat(8)

    static let chartAxisLabelFont = Font.system(
        size: chartAxisLabelFontSize,
        design: Font.Design.monospaced
    )

    static let labelFont = Font.system(
        size: labelFontSize,
        design: Font.Design.monospaced
    ).lowercaseSmallCaps()

    static let meterFont = Font.system(
        size: meterFontSize,
        design: Font.Design.monospaced
    )

    static let xScale = CGFloat(300)
    static let yScale = CGFloat(200)

    static let bodyRatio: CGFloat = 0.9
    static let labelsRatio: CGFloat = 0.1

    // Based on size of labelFont
    static let labelTextSize = CGSize(width: 2 * labelFontSize, height: 1 * labelFontSize)

    static func getLabelText(_ labelNumber: Int) -> String {
        String(format: "% 3d", labelNumber)
    }
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

extension ArkoniaLayout.LineChartView {
    static let frameWidth: CGFloat = 250
    static let frameHeight: CGFloat = 120
}

extension ArkoniaLayout.SeasonFactorView {
    static let frameWidth: CGFloat = 40

    static let bgFrameWidth: CGFloat = 40
    static var bgFrameHeight = CGFloat.zero // Set by the app startup

    static let annualTrackFrameWidth: CGFloat = 10
    static var annualTrackFrameHeight = CGFloat.zero // Set by the app startup

    static let naturalArrowHeightInAssetCatalog: CGFloat = 100

    static let annualMarkerFrameWidth: CGFloat = 10
    static let annualMarkerFrameHeight: CGFloat = 200
    static let annualMarkerFrameHeightScale: CGFloat = annualMarkerFrameHeight / naturalArrowHeightInAssetCatalog
    static let annualMarkerCornerRadius: CGFloat = 5

    static let diurnalMarkerFrameWidth: CGFloat = 15
    static let diurnalMarkerFrameHeight: CGFloat = 50
    static let diurnalMarkerFrameHeightScale: CGFloat = diurnalMarkerFrameHeight / naturalArrowHeightInAssetCatalog
}
