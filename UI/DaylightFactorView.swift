import SwiftUI

struct DaylightFactorView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

    var body: some View {
        ZStack {
            Rectangle()
                .frame(
                    width: ArkoniaLayout.DaylightFactorView.sunstickFrameWidth,
                    height: ArkoniaLayout.DaylightFactorView.sunstickFrameHeight
                )
                .cornerRadius(ArkoniaLayout.DaylightFactorView.sunstickCornerRadius)
                .foregroundColor(.gray)

            Circle()
                .frame(
                    width: ArkoniaLayout.DaylightFactorView.sunFrameWidth,
                    height: ArkoniaLayout.DaylightFactorView.sunFrameHeight
                )
                .foregroundColor(.yellow)
                .offset(x: 0, y: seasonalFactors.sunHeight)
                .animation(.linear)
        }
    }
}

struct DaylightFactorView_Previews: PreviewProvider {
    static var previews: some View {
        DaylightFactorView()
    }
}
