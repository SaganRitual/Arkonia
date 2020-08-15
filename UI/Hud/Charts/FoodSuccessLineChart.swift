import SwiftUI

struct FoodSuccessLineChart: View {
    @EnvironmentObject var stats: PopulationStats

    var body: some View { LineChartTheChartView() }
}

class FoodSuccessLineData: LineChartLineDataProtocol {
    let histogram = Histogram(10, .zeroToOne, .amLog10, .amLinear)

    func getPlotPoints() -> (CGFloat, [CGPoint]) {
        print("getpltpoints7")
        var plotPoints = [CGPoint](repeating: CGPoint.zero, count: 10)

        (0..<histogram.theBuckets.count).forEach {
            let raw = histogram.theBuckets[$0]
            let s = max(CGFloat(raw.cSamples), 1)           // Avoid div by zero
            let averageJumpsInThisSuccessRange = CGFloat(raw.sumOfAllSamples) / s
            let y = averageJumpsInThisSuccessRange < 1 ? 0 : log10(averageJumpsInThisSuccessRange)

            plotPoints[$0] = CGPoint(x: CGFloat($0), y: y)
            Debug.log(level: 226) { "y = \(y) average = \(averageJumpsInThisSuccessRange) sum = \(raw.sumOfAllSamples) cSamples = \(s)" }
        }

        let maxY = plotPoints.max { $0.y < $1.y }!.y
        let maxLogY = constrain(floor(log10(maxY) + 1), lo: 1, hi: 10)

        (0..<plotPoints.count).forEach { plotPoints[$0].x /= 10; plotPoints[$0].y /= pow(10, (maxLogY - 1)) }

        Debug.log(level: 226) { "points \(maxY) \(plotPoints)" }
        defer { histogram.reset() }
        return (maxLogY, plotPoints)
    }
}

class FoodSuccessLineChartControls {
    let akConfig = FoodSuccessLineChartConfiguration()
    let controls: LineChartControls
    let dataset: LineChartDataset

    let maxY: CGFloat = 0

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

        let line = (dataset.lines[0] as? FoodSuccessLineData)!
        let browsingSuccess = Double(cVeggieBites) / Double(cJumps)
        line.histogram.addSample(xAxis: browsingSuccess, yAxis: Double(cJumps))
    }

    func updateUI() {
        DispatchQueue.main.async {
            self.dataset.yAxisTopExponentValue = max(CGFloat(cJumps), self.dataset.yAxisTopExponentValue)
        }
    }
}
