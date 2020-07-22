import SwiftUI

struct AlmanacView: View {
    @EnvironmentObject var seasonalFactors: SeasonalFactors

    let clockFormatter = DateComponentsFormatter()

    init() {
        clockFormatter.allowedUnits = [.hour, .minute, .second]
        clockFormatter.allowsFractionalUnits = true
        clockFormatter.unitsStyle = .positional
        clockFormatter.zeroFormattingBehavior = .pad
    }

    enum Property { case elapsedTimeRealSeconds }
    func readClock(_ property: Property) -> TimeInterval {
        switch property {
        case .elapsedTimeRealSeconds: return seasonalFactors.elapsedTimeRealSeconds
        }
    }

    var labelFont: Font {
        Font.system(
            size: ArkoniaLayout.AlmanacView.labelFontSize,
            design: Font.Design.monospaced
        ).lowercaseSmallCaps()
    }

    var meterFont: Font {
        Font.system(
            size: ArkoniaLayout.AlmanacView.meterFontSize,
            design: Font.Design.monospaced
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Run duration").font(self.labelFont)
                    Spacer()
                    Text(clockFormatter.string(from: seasonalFactors.elapsedTimeRealSeconds)!)
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Year:Day").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(seasonalFactors.currentYear):\(seasonalFactors.elapsedDaysThisYear)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("p-Year:p-Day").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "%02.0f", seasonalFactors.pCurrentYear * 100)):\(String(format: "%02.0f", seasonalFactors.pCurrentDay * 100))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Temperature").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "%0.2f", seasonalFactors.temperature))")
                }.padding(.leading).padding(.trailing)

            }
            .font(self.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct AlmanacView_Previews: PreviewProvider {
    static var previews: some View {
        AlmanacView().environmentObject(SeasonalFactors())
    }
}
