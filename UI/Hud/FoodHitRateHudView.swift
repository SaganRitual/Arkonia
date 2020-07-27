import SwiftUI

struct FoodHitrateHudView: View {
    @EnvironmentObject var stats: PopulationStats
    @EnvironmentObject var mannaStats: MannaStats

    enum Format { case max, highwater, average, llamas }

    func format(_ format: Format) -> String {
        switch format {
        case .max:       return String(format: "%0.2f", Census.shared.censusAgent.stats.maxFoodHitRate)
        case .highwater: return String(format: "%0.2f", Census.shared.highwater.foodHitrate)
        case .average:   return String(format: "%0.2f", Census.shared.censusAgent.stats.averageFoodHitRate)
        case .llamas:    return String(format: "%d", 0)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max Food Hitrate").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text(format(.max))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.average))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Manna").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(
                        "\(String(format: "% 5d", mannaStats.cPhotosynthesizingManna))"
                        + "/\(String(format: "% 5d", mannaStats.cPlantedManna - mannaStats.cDeadManna))"
                    )
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Llamas").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.llamas))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
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
