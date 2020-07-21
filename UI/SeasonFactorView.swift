import SwiftUI

struct SeasonFactorView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

    var body: some View {
        ZStack {
            Rectangle()
                .frame(
                    width: ArkoniaLayout.SeasonFactorView.bgFrameWidth
                )
                .foregroundColor(Color(NSColor.darkGray))

            Rectangle()
                .frame(
                    width: ArkoniaLayout.SeasonFactorView.stickGrooveFrameWidth
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
        }.frame(maxHeight: .infinity)
    }
}

struct SeasonFactorView_Previews: PreviewProvider {
    static var previews: some View {
        SeasonFactorView()
    }
}
