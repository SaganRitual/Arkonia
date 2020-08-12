import SwiftUI

struct LineChartDataBackdrop: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getColor(_ ss: Int) -> Color {
        lineChartControls.akConfig.legendoids[ss].color
    }

    var body: some View {
        ZStack {
            GeometryReader { gr in
                Rectangle()
                    .foregroundColor(lineChartControls.akConfig.chartBackdropColor)

                self.drawGridLines(gr, .horizontal)
                self.drawGridLines(gr, .vertical)

                ForEach(lineChartControls.akConfig.legends[0].legendoidRange) { ss in
                    LineChartLineView(switchSS: ss)
                }

                ForEach(lineChartControls.akConfig.legends[0].legendoidRange) { ss in
                    LineChartLineView(switchSS: ss)
                }
            }
        }
    }
}

extension LineChartDataBackdrop {
    func drawGridLines(
        _ gProxy: GeometryProxy, _ direction: GridLinesDirection
    ) -> some View {
        let (rectWidth, rectHeight) = direction == .vertical ?
            (gProxy.size.width, 0) : (0, gProxy.size.height)

        return ForEach(0..<(5 + 1)) { ss in
            Path { path in
                if direction == .vertical {
                    path.move(
                        to: CGPoint(x: CGFloat(ss * 2) * rectWidth / 10, y: 0)
                    )

                    path.addLine(
                        to: CGPoint(x: CGFloat(ss * 2) * rectWidth / 10, y: gProxy.size.height)
                    )
                } else {
                    path.move(
                        to: CGPoint(x: 0, y: CGFloat(ss * 2) * rectHeight / 10)
                    )

                    path.addLine(
                        to: CGPoint(x: gProxy.size.width, y: CGFloat(ss * 2) * rectHeight / 10)
                    )
                }

                path.closeSubpath()
            }
            .stroke(lineWidth: 1).foregroundColor((.black))
        }
    }

}
