import SwiftUI

struct LineChartLineView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let switchSS: Int

    func fitToFrame(_ plotPoint: CGPoint, by: CGSize) -> CGPoint {
        let x = plotPoint.x * by.width
        let y = (1 - plotPoint.y) * by.height
        return CGPoint(x: x, y: y)
    }

    func midpoint(between start: CGPoint, and end: CGPoint) -> CGPoint {
        CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    }

    func visuallyCenter(point: CGPoint, scale: CGSize) -> CGPoint {
        CGPoint(x: point.x + 0.075 * scale.width, y: point.y - 0.075 / 2 * scale.height)
    }

    func drawLine(_ gProxy: GeometryProxy) -> Path {
        var path = Path()

        let `switch` = lineChartControls.switches[switchSS]
        if !`switch` { return path }

        let dataLine = lineChartControls.dataset!.lines[switchSS]
        let plotPoints = dataLine.getPlotPoints()

        let nonPlottedPoint = fitToFrame(plotPoints[0], by: gProxy.size)
        let shifted = visuallyCenter(point: nonPlottedPoint, scale: gProxy.size)
        path.move(to: shifted)

        for (pp, cp) in zip(plotPoints.dropLast(), plotPoints.dropFirst()) {
            let previousPoint = visuallyCenter(point: fitToFrame(pp, by: gProxy.size), scale: gProxy.size)
            let currentPoint = visuallyCenter(point: fitToFrame(cp, by: gProxy.size), scale: gProxy.size)
            let mp = midpoint(between: previousPoint, and: currentPoint)

            path.addQuadCurve(to: mp, control: previousPoint)
        }

        return path
    }

    var body: some View {
        GeometryReader { gr in
            self.drawLine(gr)
                .stroke(lineWidth: (gr.size.width + gr.size.height) * 0.005)
                .foregroundColor(lineChartControls.akConfig.legendoids[switchSS].color)
                .opacity(lineChartControls.switches[switchSS] ? 1 : 0)
                .frame(minWidth: 200, minHeight: 100)
        }
    }
}

class LineChartLineView_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map {
            CGPoint(x: Double($0) / 10, y: Double.random(in: 0..<1))
        }
    }
}

struct LineChartLineView_Previews: PreviewProvider {
    static var dataset = LineChartDataset(
        count: 4, constructor: { LineChartLineView_PreviewsLineData() }
    )

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var previews: some View {
        LineChartLineView(switchSS: 0)
        .frame(width: 300, height: 100)
        .environmentObject(lineChartControls)
    }
}
