import SwiftUI

struct ContentView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        LineChartLineView(switchSS: 0)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 300, height: 200)
            .environmentObject(MockLineChartControls.controls)
    }
}
