import SwiftUI

struct BrainyHudView: View {
    @EnvironmentObject var stats: PopulationStats
    @EnvironmentObject var hudUpdateTrigger: UpdateTrigger

    enum Format { case brainy, highwater, roomy, lowwater }

    func format(_ format: Format) -> String {
        Debug.log(level: 222) {
            "format \(stats.cBrainy) \(stats.highwaterStats.brainy) \(stats.cRoomy) \(stats.highwaterStats.roomy)"
        }

        switch format {
        case .brainy:    return String(format: "%d", stats.cBrainy)
        case .highwater: return String(format: "%d", stats.highwaterStats.brainy)
        case .roomy:     return String(format: "%d", stats.cRoomy)
        case .lowwater:  return String(format: "%d", stats.highwaterStats.roomy)
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Brainiest").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text(format(.brainy))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.highwater))
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Roomiest").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.roomy)
                    )
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Low water").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(format(.lowwater))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
            .foregroundColor(.green)
            .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
        }
    }
}

struct BrainyHudView_Previews: PreviewProvider {
    static var previews: some View {
        BrainyHudView().environmentObject(PopulationStats())
    }
}
