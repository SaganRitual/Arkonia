import SwiftUI

protocol LineChartConfiguration {
    var chartBackdropColor: Color { get }
    var horizontalLines: Bool { get }
    var verticalLines: Bool { get }
    var xAxisShape: AxisShape { get }
    var yAxisShape: AxisShape { get }
    var chartTitle: String { get }
    var legends: [LineChartLegendConfiguration] { get }

    func getLegend(at: AKPoint) -> LineChartLegendConfiguration?
    func getLegendoid(at: AKPoint) -> LineChartLegendoidConfiguration?
}

enum AxisShape { case linear, log }
enum GridLinesDirection { case vertical, horizontal }

struct LineChartBrowsingSuccess: LineChartConfiguration {
    let chartBackdropColor = Color.gray
    let horizontalLines = true
    let verticalLines = true
    let xAxisShape = AxisShape.linear
    let yAxisShape = AxisShape.linear

    let chartTitle = "Browsing Success"

    func getLegend(at: AKPoint) -> LineChartLegendConfiguration? {
        legends.count > at.x ? legends[at.x] : nil
    }

    func getLegendoid(at position: AKPoint) -> LineChartLegendoidConfiguration? {
        guard let legend = getLegend(at: position) else { return nil }
        return legend.legendoids.count > position.y ? legend.legendoids[position.y] : nil
    }

    let legends = [
        LineChartLegendConfiguration(
            legendTitle: "Current",
            titleEdge: .leading,
            legendoids: [
                LineChartLegendoidConfiguration(color: .red, text: "Max"),
                LineChartLegendoidConfiguration(color: .green, text: "Avg")
            ]
        ),

        LineChartLegendConfiguration(
            legendTitle: "All-Time",
            titleEdge: .trailing,
            legendoids: [
                LineChartLegendoidConfiguration(color: .blue, text: "Max"),
                LineChartLegendoidConfiguration(color: .orange, text: "Avg")
            ]
        ),
    ]

    var leadingLegendIndexes: Range<Int> { 0..<legends[0].legendoids.count }
    var trailingLegendIndexes: Range<Int> { 0..<legends[1].legendoids.count }
}

struct LineChartLegendoidConfiguration {
    let color: Color
    let text: String
}

struct LineChartLegendConfiguration {
    let legendTitle: String
    let titleEdge: Edge
    let legendoids: [LineChartLegendoidConfiguration]
}
