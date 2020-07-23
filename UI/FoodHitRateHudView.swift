import SwiftUI

struct FoodHitrateHudView: View {
    @EnvironmentObject var stats: PopulationStats
    @EnvironmentObject var mannaStats: MannaStats

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

    enum Format { case max, highwater, average, llamas }

    func format(_ format: Format) -> String {
        switch format {
        case .max:       return String(format: "%0.2f", Census.shared.censusAgent.stats.maxFoodHitRate)
        case .highwater: return String(format: "%0.2f", Census.shared.highwaterFoodHitrate)
        case .average:   return String(format: "%0.2f", Census.shared.censusAgent.stats.averageFoodHitRate)
        case .llamas:    return String(format: "%d", 0)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max Food Hitrate").font(self.labelFont)
                    Spacer()
                    Text(format(.max))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.average))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Manna").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "% 5d", mannaStats.cPhotosynthesizingManna))/\(String(format: "% 5d", mannaStats.cPlantedManna))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Llamas").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.llamas))
                }.padding(.leading).padding(.trailing)
            }
            .font(self.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct FoodHitrateHudView_Previews: PreviewProvider {
    static var previews: some View {
        FoodHitrateHudView().environmentObject(PopulationStats())
    }
}
