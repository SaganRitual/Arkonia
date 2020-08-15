import SwiftUI

struct LineChartAxisTopMarkerView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls
    @EnvironmentObject var dataset: LineChartDataset

    let whichAxis: CGPoint

    func getMode() -> AxisMode {
        (whichAxis.x == 1) ?
            foodSuccessLineChartControls.akConfig.xAxisMode :
            foodSuccessLineChartControls.akConfig.yAxisMode
    }

    func getTopMarker() -> LineChartTopMarker {
        (whichAxis.x == 1) ?
            foodSuccessLineChartControls.akConfig.xAxisTopMarker :
            foodSuccessLineChartControls.akConfig.yAxisTopMarker
    }

    func assembleMarker() -> AnyView {
        return whichAxis.x == 1 ?
            AnyView(assembleXMarker()) : AnyView(assembleYMarker())
    }

    func assembleXMarker() -> some View {
        print("x, \(dataset.xAxisTopBaseValue), \(dataset.xAxisTopExponentValue)")
            return Text("\(String(format: getTopMarker().base, dataset.xAxisTopBaseValue))")
            .offset(x: -foodSuccessLineChartControls.akConfig.axisLabelsFontSize / 2)
    }

    func assembleYMarker() -> some View {
        print("y, \(dataset.yAxisTopBaseValue), \(dataset.yAxisTopExponentValue)")
        return VStack {
            Text("\(String(format: getTopMarker().exponent, dataset.yAxisTopExponentValue))")
                .scaleEffect(0.85)
                .offset(x: foodSuccessLineChartControls.akConfig.axisLabelsFontSize / 2)

            Text("\(String(format: getTopMarker().base, dataset.yAxisTopBaseValue))")
                .offset(x: -foodSuccessLineChartControls.akConfig.axisLabelsFontSize / 2)
        }
    }

    var body: some View { assembleMarker() }
}

struct LineChartAxisView: View {
    @EnvironmentObject var foodSuccessLineChartControls: LineChartControls

    let whichAxis: CGPoint

    func getMode(_ whichAxis: CGPoint) -> AxisMode {
        (whichAxis.x == 1) ?
            foodSuccessLineChartControls.akConfig.xAxisMode :
            foodSuccessLineChartControls.akConfig.yAxisMode
    }

    func drawVertical() -> some View {
        let asArray = foodSuccessLineChartControls.akConfig.yAxisTitle.map { String($0) }

        return VStack {
            ForEach(0..<asArray.count) { Text("\(asArray[$0])") }
        }
    }

    func drawHorizontal() -> some View {
        Text(foodSuccessLineChartControls.akConfig.xAxisTitle)
            .lineLimit(1)
    }

    var body: some View {
        if whichAxis.x == 1 { drawHorizontal() }
        else if whichAxis.y == 1 { drawVertical() }
    }
}

struct LineChartAxisView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartAxisView(whichAxis: CGPoint(x: 1, y: 0))
            .environmentObject(MockLineChartControls.controls)
    }
}
