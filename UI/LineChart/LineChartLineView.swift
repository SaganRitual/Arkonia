import SwiftUI

struct LineChartLineView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let switchSS: Int

    func fitToFrame(_ plotPoint: CGPoint, by: CGSize) -> CGPoint {
        let x = plotPoint.x * by.width
        let y = (1 - plotPoint.y) * by.height * 0.98
        return CGPoint(x: x, y: y)
    }

    func midpoint(between start: CGPoint, and end: CGPoint) -> CGPoint {
        CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    }

    func translateToCoordinateSpace(sample: CGPoint, scale: CGSize) -> CGPoint {
        let xm = lineChartControls.akConfig.xAxisMode
        let ym = lineChartControls.akConfig.yAxisMode

        let axisized = CGPoint(
            x: AxisMode.adjustInputSample(sample.x, mode: xm),
            y: AxisMode.adjustInputSample(sample.y, mode: ym)
        )

        let fitted = fitToFrame(axisized, by: scale)

        return visuallyCenter(point: fitted, scale: scale)
    }

    func drawLine(_ gProxy: GeometryProxy) -> Path {
        var path = Path()

        if !lineChartControls.switches[switchSS] { return path }

        let dataLine = lineChartControls.dataset!.lines[switchSS]
        let plotPoints = dataLine.getPlotPoints()

        assert(plotPoints.allSatisfy {
            $0.x >= 0 && $0.x <= 1 && $0.y >= 0 && $0.y <= 1
        })

        let nonPlottedPoint = translateToCoordinateSpace(
            sample: plotPoints[0], scale: gProxy.size
        )

        path.move(to: nonPlottedPoint)

        for (pp, cc) in zip(plotPoints.dropLast(), plotPoints.dropFirst()) {
            let prev = translateToCoordinateSpace(sample: pp, scale: gProxy.size)
            let curr = translateToCoordinateSpace(sample: cc, scale: gProxy.size)

            let mp = midpoint(between: prev, and: curr)
            path.addLine(to: mp)
//            path.addQuadCurve(to: mp, control: prev)
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

    // y == 0 from histogram, y == 300 here
    // y == 1 from histogram, y == 0 here
    // -0.1 * h when y = 0
    // -0.05 * h when y = 1
    func visuallyCenter(point: CGPoint, scale: CGSize) -> CGPoint {
        let p = CGPoint(
            x: point.x + 0.075 * scale.width,
            y: point.y + 0.01 * scale.height
        )

        print("vc", p, point.y, point.x)
        return p
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
        .frame(width: 200, height: 100)
        .environmentObject(lineChartControls)
    }
}
