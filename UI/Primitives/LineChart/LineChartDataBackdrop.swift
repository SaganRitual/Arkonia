import SwiftUI

struct LineChartDataBackdrop: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var leadingLegendIndexes: Range<Int> { (lineChartControls.akConfig as? LineChartBrowsingSuccess)!.leadingLegendIndexes }
    var trailingLegendIndexes: Range<Int> { (lineChartControls.akConfig as? LineChartBrowsingSuccess)!.trailingLegendIndexes }

    func getColor(_ ss: Int) -> Color {
        lineChartControls.akConfig.getLegendoid(at: lineChartControls.liveLegendoidPositions[ss])!.color
    }

    var body: some View {
        ZStack {
            GeometryReader { gr in
                Rectangle()
                    .foregroundColor(lineChartControls.akConfig.chartBackdropColor)

                self.drawGridLines(gr, .horizontal)
                self.drawGridLines(gr, .vertical)

                ForEach(self.leadingLegendIndexes) { ss in
                    LineChartLineView(
                        companionCheckboxAt: lineChartControls.liveLegendoidPositions[ss],
                        viewWidth: gr.size.width, viewHeight: gr.size.height
                    )
                }

                ForEach(self.trailingLegendIndexes) { ss in
                    LineChartLineView(
                        companionCheckboxAt: lineChartControls.liveLegendoidPositions[ss + leadingLegendIndexes.upperBound],
                        viewWidth: gr.size.width, viewHeight: gr.size.height
                    )
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
