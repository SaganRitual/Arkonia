import SwiftUI

struct FoodSuccessLineChartConfiguration: LineChartConfiguration {
    let chartBackdropColor = Color(white: 0.3)
    let cHorizontalLines = 10
    let cVerticalLines = 10
    let xAxisMode = AxisMode.amLog10
    let yAxisMode = AxisMode.amLinear

    let chartTitle = "Browsing Success"
    let axisLabelsFont = FoodSuccessLineChartConfiguration.chartAxisLabelFont
    let legendFont = FoodSuccessLineChartConfiguration.meterFont
    let titleFont = FoodSuccessLineChartConfiguration.labelFont

    let xScale = CGFloat(200)
    let yScale = CGFloat(100)

    let legends = [
        LineChartLegendConfiguration(
            legendoidRange: 0..<1, legendTitle: "Current", titleEdge: .leading
        ),
        LineChartLegendConfiguration(
            legendoidRange: 0..<0, legendTitle: "All-time", titleEdge: .trailing
        )
    ]

    let legendoids = [
//        LineChartLegendoidConfiguration(color: .red, text: "Max"),
        LineChartLegendoidConfiguration(color: .green, text: "Avg")
//        LineChartLegendoidConfiguration(color: .blue, text: "Max"),
//        LineChartLegendoidConfiguration(color: .orange, text: "Avg")
    ]
}

extension FoodSuccessLineChartConfiguration {
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
