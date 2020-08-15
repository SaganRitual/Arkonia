import SwiftUI

struct LineChartTheChartView: View {
    var body: some View {
        VStack {
            LineChartHeaderView()

            LineChartAxisLabelsView()
                .background(Color.gray)
                .frame(minHeight: 100)
        }
    }
}

class LineChartTheChartView_PreviewsLineData: LineChartLineDataProtocol {
    var xAxisTopBaseValue: CGFloat = 100
    var xAxisTopExponentValue: CGFloat = 0
    var yAxisTopBaseValue: CGFloat = 10
    var yAxisTopExponentValue: CGFloat = 1

    func getPlotPoints() -> [CGPoint] {
        print("getpltpoint42")

        return (Int(0)..<Int(10)).map { CGPoint(x: Double($0), y: Double.random(in: 0..<10)) }
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
