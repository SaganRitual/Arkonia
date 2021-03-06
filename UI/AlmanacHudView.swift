import SwiftUI

struct AlmanacHudView: View {
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

    enum NumberStringFormat { case year, day, pYear, pDay, temperature }
    func format(_ format: NumberStringFormat) -> String {
        switch format {
        case .year: return String(format: "%02d", Int(seasonalFactors.currentYear))
        case .day: return String(format: "%02d", Int(seasonalFactors.elapsedDaysThisYear))
        case .pYear: return String(format: "%02.0f", min(99, seasonalFactors.pCurrentYear * 100))
        case .pDay: return String(format: "%02.0f", min(99, seasonalFactors.pCurrentDay * 100))
        case .temperature: return String(format: "%0.2f", seasonalFactors.temperature)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Run duration").font(self.labelFont)
                    Spacer()
                    Text(clockFormatter.string(from: seasonalFactors.elapsedTimeRealSeconds)!)
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Year:Day").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.year)):\(format(.day))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("p-Year:p-Day").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.pYear)):\(format(.pDay))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Temperature").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.temperature))")
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
        AlmanacHudView().environmentObject(SeasonalFactors())
    }
}
