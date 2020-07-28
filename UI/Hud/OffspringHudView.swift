import SwiftUI

struct OffspringHudView: View {
    @EnvironmentObject var stats: PopulationStats

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Max offspring").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text("\(String(format: "% 3.0f", stats.maxCOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "% 3.0f", stats.highwaterStats.cOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Average").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "% 3.2f", stats.averageCOffspring))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Median").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(String(format: "% 3.2f", stats.medCOffspring))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
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
