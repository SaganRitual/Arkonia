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

    enum NumberStringFormat { case year, day, temperature, foodValue }
    let upArrow = "⬆"
    let downArrow = "⬇"

    func format(_ format: NumberStringFormat) -> String {
        switch format {
        case .year:
            let elapsedDays = seasonalFactors.elapsedDaysThisYear
            let qYearInDays = Arkonia.arkoniaDaysPerYear / 4
            let ascending = elapsedDays < qYearInDays || elapsedDays > Arkonia.arkoniaDaysPerYear - qYearInDays
            let arrow = "\(ascending ? upArrow : downArrow)"
            return String(format: "\(arrow)%02d", Int(seasonalFactors.currentYear))

        case .day:
            let elapsedSeconds = seasonalFactors.elapsedSecondsToday
            let qDayInSeconds = Arkonia.realSecondsPerArkoniaDay / 4
            let ascending = elapsedSeconds < qDayInSeconds || elapsedSeconds > Arkonia.realSecondsPerArkoniaDay - qDayInSeconds
            let arrow = "\(ascending ? upArrow : downArrow)"
            return String(format: "\(arrow)%02d", Int(seasonalFactors.elapsedDaysThisYear))

        case .temperature: return String(format: "%0.2f", seasonalFactors.normalizedTemperature * 100)
        case .foodValue: return String(format: "%0.2f", MannaStats.stats.foodValue)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Elapsed").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text(clockFormatter.string(from: seasonalFactors.elapsedTimeRealSeconds)!)
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Year:Day").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.year))\(format(.day))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Temperature").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.temperature))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Food value").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(format(.foodValue))")
                }.padding(.leading).padding(.trailing)

            }
            .font(ArkoniaLayout.meterFont)
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
