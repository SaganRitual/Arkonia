import SpriteKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Spacer()

            SeasonFactorView()
                .frame(width: ArkoniaLayout.SeasonFactorView.frameWidth)
                .environmentObject(Clock.shared.seasonalFactors)

            VStack {
                HStack {
                    AlmanacHudView().environmentObject(Clock.shared.seasonalFactors)
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)

                    PopulationHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)
                        .environmentObject(MannaStats.stats)

                    AgeHudView()
                        .frame(width: ArkoniaLayout.AlmanacView.frameWidth)
                        .environmentObject(Census.shared.censusAgent.stats)

                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.white.opacity(0.01))
                }
                .frame(height: ArkoniaLayout.ContentView.hudHeight)

                GameView(scene: ArkoniaScene())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
