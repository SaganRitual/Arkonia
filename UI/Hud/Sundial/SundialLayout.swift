import SwiftUI

class SundialLayout: ObservableObject {
    var annualMarkerFrameHeightScale: Double = 0
    var diurnalMarkerFrameHeightScale: Double = 0
    let naturalArrowHeightInAssetCatalog: Double = 100
    let seasonalFactors = Clock.shared.seasonalFactors

    init() {
        annualMarkerFrameHeightScale =
            Double(annualMarkerFrameSize.height) /
            naturalArrowHeightInAssetCatalog

        diurnalMarkerFrameHeightScale =
            Double(diurnalMarkerFrameSize.height) /
            naturalArrowHeightInAssetCatalog
    }

    let annualTrackFrameSize = CGSize(
        width: ArkoniaLayout.SeasonFactorView.annualTrackFrameWidth,
        height: ArkoniaLayout.SeasonFactorView.annualTrackFrameHeight
    )

    let annualMarkerFrameSize = CGSize(
        width: ArkoniaLayout.SeasonFactorView.annualMarkerFrameWidth,
        height: ArkoniaLayout.SeasonFactorView.annualMarkerFrameHeight
    )

    let diurnalMarkerFrameSize = CGSize(
        width: ArkoniaLayout.SeasonFactorView.diurnalMarkerFrameWidth,
        height: ArkoniaLayout.SeasonFactorView.diurnalMarkerFrameHeight
    )

    var annualMarkerPosition: Double {
        return seasonalFactors.annualCurve * annualMarkerPositionRange
    }

    var annualMarkerPositionRange: Double {
        return Double(
            annualTrackFrameSize.height - annualMarkerFrameSize.height
        ) / 2
    }

    var annualMarkerScale: Double {
        seasonalFactors.yearCompletionPercentage * annualMarkerFrameHeightScale
    }

    var diurnalMarkerPosition: Double {
        let dc = seasonalFactors.diurnalCurve * diurnalMarkerPositionRange
        let p = seasonalFactors.formula == .simpleSineAddition ? annualMarkerPosition : 0

        return dc + p
    }

    var diurnalMarkerScale: Double {
        seasonalFactors.dayCompletionPercentage * diurnalMarkerFrameHeightScale
    }

    var diurnalMarkerPositionRange: Double {
        Double(annualMarkerFrameSize.height - diurnalMarkerFrameSize.height) / 2
    }

    var seasonIsAscending: Bool {
        (0..<0.25).contains(seasonalFactors.yearCompletionPercentage) ||
            (0.75..<1).contains(seasonalFactors.yearCompletionPercentage)
    }

    var sunIsAscending: Bool {
        (0..<0.25).contains(seasonalFactors.dayCompletionPercentage) ||
            (0.75..<1).contains(seasonalFactors.dayCompletionPercentage)
    }
}
