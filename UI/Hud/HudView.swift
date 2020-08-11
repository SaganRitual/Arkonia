import SwiftUI

struct HudView: View {
    var body: some View {
        HStack {
            Spacer()

            AlmanacHudView().environmentObject(Clock.shared.seasonalFactors)
                .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

            PopulationHudView()
                .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

            AgeHudView()
                .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

            OffspringHudView()
                .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

            NeuronsHudView()
                .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

            Spacer()
        }
    }
}

struct HudView_Previews: PreviewProvider {
    static var previews: some View {
        HudView()
    }
}
