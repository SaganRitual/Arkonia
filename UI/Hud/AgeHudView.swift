import SwiftUI

struct AgeHudView: View {
    @EnvironmentObject var stats: PopulationStats

    enum Format { case maxAge, highwaterAge, averageAge, medAge }

    func format(_ format: Format) -> String {
        switch format {
        case .maxAge:       return String(format: "%.0f", stats.maxAge)
        case .highwaterAge: return String(format: "%.0f", Census.shared.highwater.age)
        case .averageAge:   return String(format: "%.2f", stats.averageAge)
        case .medAge:       return String(format: "%.2f", stats.medAge)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max Age").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text(format(.maxAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.highwaterAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.averageAge))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Median").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.medAge))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
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
