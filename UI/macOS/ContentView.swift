import SwiftUI

struct ContentView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    var body: some View {
        LineChartTheChartView()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockLineChartControls.controls)
    }
}
