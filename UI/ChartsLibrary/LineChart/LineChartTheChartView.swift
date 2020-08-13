import SwiftUI

struct LineChartTheChartView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        VStack {
            LineChartHeaderView()

            LineChartAxisLabelsView()
                .background(Color.gray)
                .frame(maxHeight: 1.1 * 100)
        }
        .frame(maxWidth: 1.1 * 200)
        .padding([.trailing])
        .background(Color(white: 0.3))
    }
}

class LineChartTheChartView_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map { CGPoint(x: Double($0), y: Double.random(in: 0..<10)) }
    }
}

struct LineChartTheChartView_Previews: PreviewProvider {
    static func startViewTick() -> LineChartControls {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: update)
        return MockLineChartControls.controls
    }

    static func update() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: update)
    }

    static var previews: some View {
        LineChartTheChartView().environmentObject(startViewTick())
    }
}
