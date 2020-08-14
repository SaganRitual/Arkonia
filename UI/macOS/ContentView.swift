import SwiftUI

struct ContentView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        LineChartDataBackdrop()
//        LineChartTheChartView()
//            .padding(.top, 3)
//            .border(Color.black)
//            .background(lineChartControls.akConfig.chartBackdropColor)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MockLineChartControls.controls)
    }
}
