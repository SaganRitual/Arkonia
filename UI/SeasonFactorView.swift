import SwiftUI

extension Angle {
    // This hopefully will help me not to confuse this with 2pi in the code below
    static let pi = Angle.radians(Double.pi)
}

struct SeasonFactorView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

    let qDay = Arkonia.realSecondsPerArkoniaDay / 4
    let qYear = Arkonia.realSecondsPerArkoniaDay * Arkonia.arkoniaDaysPerYear  / 4

    var diurnalArrowFrameHeight: CGFloat {
        let c = ArkoniaLayout.SeasonFactorView.diurnalArrowFrameHeightScale *
        ArkoniaLayout.SeasonFactorView.naturalArrowHeightInAssetCatalog
        return c
    }

    var seasonalArrowFrameHeight: CGFloat {
        let c = (ArkoniaLayout.SeasonFactorView.seasonalArrowFrameHeightScale *
                ArkoniaLayout.SeasonFactorView.naturalArrowHeightInAssetCatalog)
        return c
    }

    func scaleDiurnalCurveToSeasonalArrowPosition() -> CGFloat {
        let scaleToSeasonalArrowFrameRange: CGFloat =
            (seasonalArrowFrameHeight - diurnalArrowFrameHeight) / 2

        return scaleSeasonalCurveToAnnualTrackPosition() + (-1 * scaleToSeasonalArrowFrameRange * seasonalFactors.diurnalCurve * 0.9)
    }

    func scaleSeasonalCurveToAnnualTrackPosition() -> CGFloat {
        let scaleToTrackFrameRange: CGFloat =
            (ArkoniaLayout.SeasonFactorView.annualTrackFrameHeight - seasonalArrowFrameHeight) / 2

        return -1 * scaleToTrackFrameRange * seasonalFactors.seasonalCurve
    }

    var sunIsAscending: Bool {
        (0..<qDay).contains(seasonalFactors.elapsedSecondsToday) ||
        ((Arkonia.realSecondsPerArkoniaDay - qDay)...).contains(seasonalFactors.elapsedSecondsToday)
    }

    var seasonIsAscending: Bool {
        return (0..<qYear).contains(seasonalFactors.elapsedSecondsThisYear) ||
        ((seasonalFactors.secondsPerYear - qYear)...).contains(seasonalFactors.elapsedSecondsThisYear)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(
                    width: ArkoniaLayout.SeasonFactorView.bgFrameWidth,
                    height: ArkoniaLayout.SeasonFactorView.bgFrameHeight
                )
                .foregroundColor(Color(NSColor.darkGray))

            Rectangle()
                .frame(
                    width: ArkoniaLayout.SeasonFactorView.annualTrackFrameWidth,
                    height: ArkoniaLayout.SeasonFactorView.annualTrackFrameHeight
                )
                .cornerRadius(5)
                .foregroundColor(Color(NSColor(calibratedWhite: 0.1, alpha: 1)))

            // Time of year
            Image("sundial")
                .blendMode(.hardLight)
                .colorMultiply(.yellow)
                .opacity(0.7)
                .scaleEffect(CGSize(width: 1.5, height: (seasonIsAscending ? 1 : -1) * ArkoniaLayout.SeasonFactorView.seasonalArrowFrameHeightScale))
                .offset(y: scaleSeasonalCurveToAnnualTrackPosition())
                .animation(.easeInOut)

            // Time of day
            Image("sundial")
                .blendMode(.normal)
                .colorMultiply(.gray)
                .colorMultiply(.green)
                .scaleEffect(CGSize(width: 0.5, height: (sunIsAscending ? 1 : -1) * ArkoniaLayout.SeasonFactorView.diurnalArrowFrameHeightScale))
                .offset(y: scaleDiurnalCurveToSeasonalArrowPosition())
                .animation(.easeInOut)
        }
    }
}

struct SeasonFactorView_Previews: PreviewProvider {
    static var previews: some View {
        return SeasonFactorView().environmentObject(SeasonalFactors())
    }
}
