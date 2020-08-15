import SwiftUI

struct LineChartDataBackdrop: View {
    let lineChartControls: LineChartControls

    init(_ c: LineChartControls) { self.lineChartControls = c }

    func getColor(_ ss: Int) -> Color {
        lineChartControls.akConfig.legendoids[ss].color
    }

    let stretch: CGFloat = 1.0 / 0.85

    var body: some View {
        GeometryReader { gr in
            ZStack {
                Rectangle()
                    .foregroundColor(lineChartControls.akConfig.chartBackdropColor)

                self.drawGridLines(gr, .horizontal)
                self.drawGridLines(gr, .vertical)
            }
            .overlay(
                ZStack {
                    ForEach(lineChartControls.akConfig.legends[0].legendoidRange) { ss in
                        LineChartLineView(lineChartControls, switchSS: ss)
                    }
//
//                    ForEach(lineChartControls.akConfig.legends[1].legendoidRange) { ss in
//                        LineChartLineView(switchSS: ss)
//                    }
                }
                // Scale the plots to the full 10x10 grid. The 0.85 is
                // because when we draw a quad curve, we plot the last
                // point at the midpoint betwen 0.8 & 0.9, so all our lines
                // stop at x = 0.85
                .scaleEffect(CGSize(width: stretch, height: 1.0))
                .offset(x: (stretch - 1) / 2 * gr.size.width)
            )
        }
    }
}

extension LineChartDataBackdrop {
    func drawGridLines(
        _ gProxy: GeometryProxy, _ direction: GridLinesDirection
    ) -> some View {
        let cLines = direction == .vertical ?
            lineChartControls.akConfig.cVerticalLines :
            lineChartControls.akConfig.cHorizontalLines

        return ForEach(0..<(cLines + 1)) { ss in
            Path { path in
                let lineIx = CGFloat(ss) / CGFloat(cLines)
                let movingX = lineIx * gProxy.size.width
                let movingY = lineIx * gProxy.size.height

                let start, end: CGPoint
                if direction == .vertical {
                    start = CGPoint(x: movingX, y: 0)
                    end = CGPoint(x: movingX, y: gProxy.size.height)
                } else {
                    start = CGPoint(x: 0, y: movingY)
                    end = CGPoint(x: gProxy.size.width, y: movingY)
                }

                path.move(to: start)
                path.addLine(to: end)
                path.closeSubpath()
            }.stroke(lineWidth: 1).foregroundColor(.black)
        }
    }
}
//
//struct LineChartDataBackdrop_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChartDataBackdrop()
//            .environmentObject(MockLineChartControls.controls)
//    }
//}