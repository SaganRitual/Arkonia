import SwiftUI

struct AgeHudView: View {
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

    enum Format { case maxAge, highwaterAge, averageAge, medAge }

    func format(_ format: Format) -> String {
        switch format {
        case .maxAge:       return String(format: "%.0f", Census.shared.censusAgent.stats.maxAge)
        case .highwaterAge: return String(format: "%.0f", Census.shared.highwaterAge)
        case .averageAge:   return String(format: "%.2f", Census.shared.censusAgent.stats.averageAge)
        case .medAge:       return String(format: "%.2f", Census.shared.censusAgent.stats.medAge)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max Age").font(self.labelFont)
                    Spacer()
                    Text(format(.maxAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.highwaterAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.averageAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Median").font(self.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.medAge))
                }.padding(.leading).padding(.trailing)
            }
            .font(self.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct AgeHudView_Previews: PreviewProvider {
    static var previews: some View {
        AgeHudView().environmentObject(PopulationStats())
    }
}
