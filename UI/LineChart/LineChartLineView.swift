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

    func translateToCoordinateSpace(sample: CGPoint, scale: CGSize) -> CGPoint {
        let xm = lineChartControls.akConfig.xAxisMode
        let ym = lineChartControls.akConfig.yAxisMode

        let axisized = CGPoint(
            x: AxisMode.adjustInputSample(sample.x, mode: xm) / 10,
            y: AxisMode.adjustInputSample(sample.y, mode: ym) / 10
        )

        let fitted = fitToFrame(axisized, by: scale)

        return visuallyCenter(point: fitted, scale: scale)
    }

    func visuallyCenter(point: CGPoint, scale: CGSize) -> CGPoint {
        CGPoint(x: point.x + 0.075 * scale.width, y: point.y - 0.075 * scale.height)
    }

    func drawLine(_ gProxy: GeometryProxy) -> Path {
        var path = Path()

        if !lineChartControls.switches[switchSS] { return path }

        let dataLine = lineChartControls.dataset!.lines[switchSS]
        let plotPoints = dataLine.getPlotPoints()

        let nonPlottedPoint = translateToCoordinateSpace(
            sample: plotPoints[0], scale: gProxy.size
        )

        path.move(to: nonPlottedPoint)

        for (pp, cc) in zip(plotPoints.dropLast(), plotPoints.dropFirst()) {
            let prev = translateToCoordinateSpace(sample: pp, scale: gProxy.size)
            let curr = translateToCoordinateSpace(sample: cc, scale: gProxy.size)

            let mp = midpoint(between: prev, and: curr)

            path.addQuadCurve(to: mp, control: prev)
        }

        return path
    }

    var body: some View {
        GeometryReader { gr in
            self.drawLine(gr)
                .stroke(lineWidth: (gr.size.width + gr.size.height) * 0.003)
                .foregroundColor(lineChartControls.akConfig.legendoids[switchSS].color)
                .opacity(lineChartControls.switches[switchSS] ? 1 : 0)
                .frame(minWidth: 200, minHeight: 100)
        }
    }
}

class LineChartLineView_PreviewsLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map {
            CGPoint(x: pow(10, Double($0)), y: Double.random(in: 0..<10))
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
        .frame(width: 300, height: 200)
        .environmentObject(lineChartControls)
    }
}
