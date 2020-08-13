//
//  LineChartAxisLabelsView.swift
//  Charts
//
//  Created by Rob Bishop on 8/12/20.
//

import SwiftUI

struct LineChartAxisLabelsView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    func getLabelText() -> some View {
        switch lineChartControls.akConfig.yAxisMode {
        case .amLinear: return Text("5")
        case .amLog:    return Text("e") + Text("5").baselineOffset(6)
        case .amLog2:   return Text("2") + Text("5").baselineOffset(6)
        case .amLog10:  return Text("10") + Text("5").baselineOffset(6)
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

                    getLabelText()
                        .font(lineChartControls.akConfig.axisLabelsFont)
                        .offset(x: -gr.size.width * 0.45, y: -gr.size.height * 0.2)
                        .font(lineChartControls.akConfig.legendFont)
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
