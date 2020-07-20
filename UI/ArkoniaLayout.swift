import CoreGraphics

enum ArkoniaLayout {
    enum ButtonsView {}
    enum ContentView {}
    enum DaylightFactorView {}
    enum SeasonFactorView {}
}

extension ArkoniaLayout.ButtonsView {
    static let buttonLabelsFrameMinWidth: CGFloat = 75
}

extension ArkoniaLayout.ContentView {
    static let frameHeight: CGFloat = 200
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
    static let bgFrameHeight: CGFloat = 350

    static let stickGrooveFrameWidth: CGFloat = 10
    static let stickGrooveFrameHeight: CGFloat = 350

    static let tempIndicatorFrameWidth = bgFrameWidth
    static let tempIndicatorFrameHeight: CGFloat = 3
}
