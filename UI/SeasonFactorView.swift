import SwiftUI

struct SeasonFactorView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

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
                    width: ArkoniaLayout.SeasonFactorView.stickGrooveFrameWidth,
                    height: ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight
                )
                .cornerRadius(5)
                .foregroundColor(Color(NSColor(calibratedWhite: 0.1, alpha: 1)))

            Rectangle()
                .frame(
                    width: ArkoniaLayout.SeasonFactorView.tempIndicatorFrameWidth,
                    height: ArkoniaLayout.SeasonFactorView.tempIndicatorFrameHeight
                )
                .foregroundColor(.black)
                .offset(x: 0, y: seasonalFactors.sunstickHeight + seasonalFactors.sunHeight)
                .animation(.linear)

            DaylightFactorView()
                .environmentObject(seasonalFactors)
                .offset(x: 0, y: seasonalFactors.sunstickHeight)
                .animation(.linear)
        }
    }
}

struct SeasonFactorView_Previews: PreviewProvider {
    static var previews: some View {
        return SeasonFactorView().environmentObject(SeasonalFactors())
    }
}
