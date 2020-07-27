import SwiftUI

struct NeuronsHudView: View {
    @EnvironmentObject var stats: PopulationStats

    enum Format { case cLiveNeurons, highwaterLive, cAverageNeurons, highwaterAverage }

    func format(_ format: Format) -> String {
        switch format {
        case .cLiveNeurons:     return String(format: "%d", Census.shared.censusAgent.stats.cNeurons)
        case .highwaterLive:    return String(format: "%d", Census.shared.highwater.cLiveNeurons)
        case .cAverageNeurons:  return String(format: "%0.2f", Census.shared.censusAgent.stats.cAverageNeurons)
        case .highwaterAverage: return String(format: "%0.2f", Census.shared.highwater.cAverageNeurons)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Live neurons").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text(format(.cLiveNeurons))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.highwaterLive))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Per Arkon").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.cAverageNeurons)
                    )
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.highwaterAverage))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct NeuronsHudView_Previews: PreviewProvider {
    static var previews: some View {
        NeuronsHudView().environmentObject(PopulationStats())
    }
}
