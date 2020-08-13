import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getLabelText(_ value: Int) -> AnyView {
        switch lineChartControls.akConfig.yAxisMode {
        case .amLinear: return AnyView(HStack { Text("\(value)") } )
        case .amLog10:  return AnyView(HStack { Text("10").padding(.trailing, -5); Text("\(value)").baselineOffset(20).padding(.leading, -2) } )
        default: fatalError()
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { gr in
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: gr.size.width * 0.1)
                        .overlay(
                            VStack {
                                ForEach(0..<4) {
                                    Text("\(8 - 2 * $0)")
                                        .font(lineChartControls.akConfig.legendFont)
                                        .frame(height: 0.175 * gr.size.height)
                                }.offset(y: -0.075 * gr.size.height)
                            }
                        )

                    VStack(spacing: 0) {
                        LineChartDataBackdrop()

                        Spacer()
                            .frame(
                                width: gr.size.width * 0.9,
                                height: gr.size.width * 0.1 // Note: my HEIGHT same as the other guy's WIDTH
                            )
                            .overlay(
                                HStack {
                                    ForEach(0..<4) {
                                        Text("\(2 + 2 * $0)")
                                            .font(lineChartControls.akConfig.legendFont)
                                            .frame(width: 0.15 * gr.size.width)
                                    }
                                }
                            )
                    }
                }
            }
        }
        .background(lineChartControls.akConfig.chartBackdropColor)
        .frame(
            minWidth: 1.1 * lineChartControls.akConfig.xScale,
            minHeight: 1.1 * lineChartControls.akConfig.yScale
        )
    }
}

struct LineChartAxisLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartAxisLabelsView()
            .frame(width: 300, height: 200)
            .environmentObject(MockLineChartControls.controls)
    }
}
