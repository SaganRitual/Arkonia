import SwiftUI

struct LineChartLineView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let companionCheckboxAt: AKPoint
    let viewWidth: CGFloat
    let viewHeight: CGFloat

    func drawLine() -> Path {
        var path = Path()

        let `switch` = lineChartControls.getLegendoidSwitch(at: companionCheckboxAt)
        if !`switch` { return path }

        let histogram = lineChartControls.getHistogram(at: companionCheckboxAt)
        guard let yValues = histogram.getScalarDistribution(reset: true) else {
            return path
        }

        let points: [CGPoint] = zip(Int(0)..., yValues).map {
            let p1 = CGPoint(x: CGFloat($0), y: $1)
            let p2 = CGPoint(x: 1.175 / 10 * viewWidth, y: -viewHeight)
            let p3 = CGPoint(x: 0, y: viewHeight)

            return p1 * p2 + p3
        }

        path.move(to: points[0])

        for (previousPoint, currentPoint) in zip(points.dropLast(), points.dropFirst()) {
            let midPoint = (previousPoint + currentPoint) / 2
            path.addQuadCurve(to: midPoint, control: previousPoint)
        }

        return path
    }

    var body: some View {
        self.drawLine()
            .stroke(lineWidth: 3)
            .foregroundColor(lineChartControls.akConfig.getLegendoid(at: companionCheckboxAt)!.color)
            .opacity(lineChartControls.getLegendoidSwitch(at: companionCheckboxAt) ? 1 : 0)
    }
}
