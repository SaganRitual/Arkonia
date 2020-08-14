import SwiftUI

struct LineChartDataBackdrop: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getColor(_ ss: Int) -> Color {
        lineChartControls.akConfig.legendoids[ss].color
    }

    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(lineChartControls.akConfig.chartBackdropColor)

                    self.drawGridLines(gr, .horizontal)
                    self.drawGridLines(gr, .vertical)
                }
                .overlay(
                    ZStack {
                        Group {
                            ForEach(lineChartControls.akConfig.legends[0].legendoidRange) { ss in
                                LineChartLineView(switchSS: ss)
                            }

                            ForEach(lineChartControls.akConfig.legends[1].legendoidRange) { ss in
                                LineChartLineView(switchSS: ss)
                            }
                        }
                        .scaleEffect(CGSize(width: 1.0 / 0.85, height: 1.0))
                        .offset(x: ((1.0 / 0.85) - 1) / 2 * gr.size.width)
                    }
                )
            }
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

struct LineChartDataBackdrop_Previews: PreviewProvider {
    static var previews: some View {
        LineChartDataBackdrop()
            .environmentObject(MockLineChartControls.controls)
    }
}
