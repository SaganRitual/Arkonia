import SwiftUI

struct LineChartLineView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let legendSS: Int
    let legendoidSS: Int
    let switchSS: Int

    let viewWidth: CGFloat
    let viewHeight: CGFloat

    func drawLine() -> Path {
        var path = Path()

        if stats.histogramsUpdateTrigger < 0 { return path }

        let `switch` = lineChartControls.switches[switchSS]
        if !`switch` { return path }

        let histogram = lineChartControls.getHistogram(switchSS)
        guard let yValues = histogram.getScalarDistribution(reset: true) else {
            return path
        }

        Debug.log(level: 225) { "yValues = \(yValues)" }

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
