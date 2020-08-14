import SwiftUI

struct LineChartLineView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    let switchSS: Int

    func midpoint(between start: CGPoint, and end: CGPoint) -> CGPoint {
        CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
    }

    func scalePointToFrame(_ point: CGPoint, scale: CGSize) -> CGPoint {
        assert(point.x >= 0 && point.x <= 1 && point.y >= 0 && point.y <= 1)
        return CGPoint(x: point.x * scale.width, y: point.y * scale.height)
    }

    func drawLine(_ gProxy: GeometryProxy) -> Path {
        var path = Path()

        if !lineChartControls.switches[switchSS] { return path }

        let dataLine = lineChartControls.dataset!.lines[switchSS]
        let plotPoints = dataLine.getPlotPoints().map {
            scalePointToFrame($0, scale: gProxy.size)
        }

        path.move(to: plotPoints[0])

        for (prev, curr) in zip(plotPoints.dropLast(), plotPoints.dropFirst()) {
            let mp = midpoint(between: prev, and: curr)
            path.addQuadCurve(to: mp, control: prev)
        }

//        path.move(to: CGPoint(x: 0.35 * gProxy.size.width, y: 0.25 * gProxy.size.height))
//        path.addLine(to: CGPoint(x: 0.5 * gProxy.size.width, y: gProxy.size.height))
//        path.addLine(to: CGPoint(x: 0.85 * gProxy.size.width, y: 0.6 * gProxy.size.height))
//        path.addLine(to: CGPoint(x: 0, y: 0))
//        path.closeSubpath()

        return path
    }

    var body: some View {
        GeometryReader { gr in
            self.drawLine(gr)
                .stroke(lineWidth: (gr.size.width + gr.size.height) * 0.003)
                .foregroundColor(lineChartControls.akConfig.legendoids[switchSS].color)
                .opacity(lineChartControls.switches[switchSS] ? 1 : 0)
                .scaleEffect(CGSize(width: 1.0, height: -1.0))
        }
    }
}

struct LineChartLineView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartLineView(switchSS: 0)
            .frame(width: 200, height: 100)
            .environmentObject(MockLineChartControls.controls)
    }
}
