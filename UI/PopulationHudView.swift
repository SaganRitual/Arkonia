import SwiftUI

struct PopulationHudView: View {
    @EnvironmentObject var stats: PopulationStats

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
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Population").font(self.labelFont)
                    Spacer()
                    Text("\(Census.shared.censusAgent.stats.currentPopulation)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(Census.shared.highwaterPopulation)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("All births").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(Census.shared.censusAgent.stats.allBirths)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Neurons").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(String(format: "%d", Census.shared.censusAgent.stats.cNeurons))
                }.padding(.leading).padding(.trailing)
            }
            .font(self.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct PopulationHudView_Previews: PreviewProvider {
    static var previews: some View {
        PopulationHudView().environmentObject(PopulationStats())
    }
}
