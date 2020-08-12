import SwiftUI

enum AxisMode {
    case amLinear, amLog, amLog2, amLog10

    static func adjustInputSample(_ sample: CGFloat, mode: AxisMode) -> CGFloat {
        switch mode {
        case .amLinear: return sample
        case .amLog:    return log(sample)
        case .amLog2:   return log2(sample)
        case .amLog10:  return log10(sample)
        }
    }
}

enum GridLinesDirection { case vertical, horizontal }

struct LineChartLegendoidConfiguration {
    let color: Color
    let text: String
}

struct LineChartLegendConfiguration {
    let legendoidRange: Range<Int>
    let legendTitle: String
    let titleEdge: Edge
}

protocol LineChartConfiguration {
    var chartBackdropColor: Color { get }
    var chartTitle: String { get }

    var cHorizontalLines: Int { get }
    var cVerticalLines: Int { get }

    var xAxisMode: AxisMode { get }
    var yAxisMode: AxisMode { get }
    var xScale: CGFloat { get }
    var yScale: CGFloat { get }

    var legendFont: Font { get }
    var titleFont: Font { get }

    var legends: [LineChartLegendConfiguration] { get }
    var legendoids: [LineChartLegendoidConfiguration] { get }
}

struct LineChartBrowsingSuccess: LineChartConfiguration {
    let chartBackdropColor = Color.gray
    let cHorizontalLines = 10
    let cVerticalLines = 10
    let xAxisMode = AxisMode.amLinear
    let yAxisMode = AxisMode.amLinear

    let chartTitle = "Browsing Success"
    let legendFont = LineChartBrowsingSuccess.meterFont
    let titleFont = LineChartBrowsingSuccess.labelFont

    let xScale = CGFloat(300)
    let yScale = CGFloat(200)

    let legends = [
        LineChartLegendConfiguration(
            legendoidRange: 0..<2, legendTitle: "Current", titleEdge: .leading
        ),
        LineChartLegendConfiguration(
            legendoidRange: 2..<4, legendTitle: "All-time", titleEdge: .leading
        )
    ]

    let legendoids = [
        LineChartLegendoidConfiguration(color: .red, text: "Max"),
        LineChartLegendoidConfiguration(color: .green, text: "Avg"),
        LineChartLegendoidConfiguration(color: .blue, text: "Max"),
        LineChartLegendoidConfiguration(color: .orange, text: "Avg")
    ]
}

extension LineChartBrowsingSuccess {
    static let chartAxisLabelFontSize = CGFloat(10)
    static let labelFontSize = CGFloat(10)
    static let meterFontSize = CGFloat(8)


    static let chartAxisLabelFont = Font.system(
        size: chartAxisLabelFontSize,
        design: Font.Design.monospaced
    )

    static let labelFont = Font.system(
        size: labelFontSize,
        design: Font.Design.monospaced
    ).lowercaseSmallCaps()

    static let meterFont = Font.system(
        size: meterFontSize,
        design: Font.Design.monospaced
    )
}
