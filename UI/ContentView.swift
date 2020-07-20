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
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity)

                    ButtonsView()
                }.frame(height: ArkoniaLayout.ContentView.frameHeight)

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
