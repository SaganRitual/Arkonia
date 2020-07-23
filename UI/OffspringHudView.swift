import SwiftUI

struct OffspringHudView: View {
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

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max offspring").font(self.labelFont)
                    Spacer()
                    Text("\(String(format: "% 3.0f", Census.shared.censusAgent.stats.maxCOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "% 3.0f", Census.shared.highwaterCOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "% 3.2f", Census.shared.censusAgent.stats.averageCOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Median").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(String(format: "% 3.2f", Census.shared.censusAgent.stats.medCOffspring))
                }.padding(.leading).padding(.trailing)
            }
            .font(self.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct OffspringHudView_Previews: PreviewProvider {
    static var previews: some View {
        OffspringHudView().environmentObject(PopulationStats())
    }
}
