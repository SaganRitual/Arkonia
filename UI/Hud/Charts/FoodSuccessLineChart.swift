import SwiftUI

struct FoodSuccessLineChart: View {
    var body: some View { LineChartTheChartView(Census.shared.censusAgent.stats.foodSuccessLineChartControls.controls) }
}

class FoodSuccessLineData: LineChartLineDataProtocol {
    let histogram = Histogram(10, .zeroToOne, .amLog10, .amLinear)

    func getPlotPoints() -> (CGFloat, [CGPoint]) {
        var plotPoints = [CGPoint](repeating: CGPoint.zero, count: 10)

        (0..<histogram.theBuckets.count).forEach {
            let raw = histogram.theBuckets[$0]
            let cSamples = max(Double(raw.cSamples), 1)           // Avoid div by zero
            let averageJumpsInThisSuccessRange = raw.sumOfAllSamples / cSamples

            plotPoints[$0] = CGPoint(x: Double($0), y: averageJumpsInThisSuccessRange)
            Debug.log(level: 228) { "raw Y average = \(averageJumpsInThisSuccessRange) sum = \(raw.sumOfAllSamples) cSamples = \(cSamples)" }
        }

        let maxY = plotPoints.max { $0.y < $1.y }!.y
        let maxLogY = (maxY > 0) ? log10(maxY) : 0
        let divLogY = floor(maxLogY + 0.5)

        (0..<plotPoints.count).forEach { pointSS in
            Debug.log(level: 228) { "points1 [\(pointSS)] \(maxLogY) \(plotPoints[pointSS].y), \(divLogY), \(pow(10, divLogY))" }
            plotPoints[pointSS].x /= 10; plotPoints[pointSS].y /= pow(10, divLogY)
        }

        Debug.log(level: 229) { "points2 \(maxLogY) \(divLogY) \(plotPoints)" }
        defer { histogram.reset() }
        return (maxLogY, plotPoints)
    }
}

class FoodSuccessLineChartControls {
    let akConfig = FoodSuccessLineChartConfiguration()
    let controls: LineChartControls
    let dataset: LineChartDataset

    init() {
        dataset = LineChartDataset(
            count: akConfig.legendoids.count,
            constructor: { FoodSuccessLineData() }
        )

        controls = LineChartControls(akConfig, dataset)
    }

    func addSample(cJumps: Int, cVeggieBites: Int) {
        // It's incredibly unlikely that anyone will get
        // a 100% success rate, so if it looks like they do, ignore them.
        // Also, don't track anyone who hasn't jumped yet
        if cJumps == cVeggieBites || cJumps == 0 { return }

        Debug.log(level: 228) { "addSample(\(cJumps), \(cVeggieBites))" }
        let line = (dataset.lines[0] as? FoodSuccessLineData)!
        let browsingSuccess = Double(cVeggieBites) / Double(cJumps)
        line.histogram.addSample(xAxis: browsingSuccess, yAxis: Double(cJumps))
    }
}
