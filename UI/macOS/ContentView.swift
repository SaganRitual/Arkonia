import SwiftUI

struct ContentView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        LineChartLineView(switchSS: 0)
    }
}

class LineChartContentView_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map {
            let p = CGPoint(x: Double($0), y: Double.random(in: 0..<10))
            print("lccv", p)
            return p
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataset = LineChartDataset(
        count: 4, constructor: { LineChartContentView_PreviewsLineData() }
    )

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var previews: some View {
        ContentView()
            .frame(width: 300, height: 200)
            .environmentObject(lineChartControls)
    }
}
