import SwiftUI

struct PopulationHudView: View {
    @EnvironmentObject var stats: PopulationStats

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white.opacity(0.01))
                .border(Color.black)

            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Population").font(ArkoniaLayout.labelFont)
                    Spacer()
                    Text("\(Census.shared.censusAgent.stats.currentPopulation)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Highwater").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(Census.shared.highwater.population)")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("All births").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text("\(String(format: "%d", Census.shared.censusAgent.stats.allBirths))")
                }.padding(.leading).padding(.trailing)

                HStack(alignment: .bottom) {
                    Text("Neurons").font(ArkoniaLayout.labelFont).padding(.top, 5)
                    Spacer()
                    Text(String(format: "%d", Census.shared.censusAgent.stats.cNeurons))
                }.padding(.leading).padding(.trailing)
            }
            .font(ArkoniaLayout.meterFont)
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
