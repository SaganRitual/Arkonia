import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getLabelText(_ value: Int) -> AnyView {
        switch lineChartControls.akConfig.yAxisMode {
        case .amLinear: return AnyView(HStack { Text("\(value)") } )
        case .amLog:    assert(false); return AnyView(HStack { Text("e"); Text("5)").baselineOffset(6) } )
        case .amLog2:   assert(false); return AnyView(HStack { Text("2"); Text("5").baselineOffset(6) } )
        case .amLog10:  return AnyView(HStack { Text("10").padding(.trailing, -5); Text("\(value)").baselineOffset(20).padding(.leading, -2) } )
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { gr in
                ZStack {
                    Rectangle()
                        .frame(
                            width: gr.size.width * 1.2,
                            height: gr.size.height * 1.2
                        )
                        .foregroundColor(lineChartControls.akConfig.chartBackdropColor)

                    ForEach(0..<4) {
                        getLabelText(($0 + 1) * 2)
                            .font(lineChartControls.akConfig.axisLabelsFont)
                            .offset(
                                x: -gr.size.width * 0.45,
                                y: ((1 - gr.size.height) / 6.25) * CGFloat($0) + 0.05 * gr.size.height
                            )

                        getLabelText(($0 + 1) * 2)
                            .font(lineChartControls.akConfig.axisLabelsFont)
                            .offset(
                                x: -gr.size.width * 0.23 + CGFloat($0) * gr.size.width * 0.16,
                                y: gr.size.height * 0.30
                            )
                    }
                }

                LineChartDataBackdrop()
                    .frame(width: gr.size.width * 0.8, height: gr.size.height * 0.8)
                    .offset(x: gr.size.width * 0.2, y: gr.size.height * 0.015)
            }
        }
    }
}

struct LineChartAxisLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartAxisLabelsView()
            .frame(width: 300, height: 200)
            .environmentObject(MockLineChartControls.controls)
    }
}
