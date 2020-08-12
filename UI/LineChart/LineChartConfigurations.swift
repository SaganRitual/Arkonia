import SwiftUI

enum AxisShape { case linear, log }
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

    var horizontalLines: Bool { get }
    var verticalLines: Bool { get }

    var xAxisShape: AxisShape { get }
    var yAxisShape: AxisShape { get }

    var legendFont: Font { get }
    var titleFont: Font { get }

    var legends: [LineChartLegendConfiguration] { get }
    var legendoids: [LineChartLegendoidConfiguration] { get }
}

struct LineChartBrowsingSuccess: LineChartConfiguration {
    let chartBackdropColor = Color.gray
    let horizontalLines = true
    let verticalLines = true
    let xAxisShape = AxisShape.linear
    let yAxisShape = AxisShape.linear

    let chartTitle = "Browsing Success"
    let legendFont = LineChartBrowsingSuccess.meterFont
    let titleFont = LineChartBrowsingSuccess.labelFont

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
