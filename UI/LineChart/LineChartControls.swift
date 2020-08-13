import SwiftUI

protocol LineChartLineDataProtocol: class {
    func getPlotPoints() -> [CGPoint]
}

class LineChartDataset {
    let lines: [LineChartLineDataProtocol]

    init(count: Int, constructor: () -> LineChartLineDataProtocol) {
        self.lines = (0..<count).map { _ in constructor() }
    }
}

class LineChartControls: ObservableObject {
    @Published var switches = [Bool](repeating: true, count: 6)

    let akConfig: LineChartConfiguration
    let scale: CGSize

    weak var dataset: LineChartDataset?

    init(_ akConfig: LineChartConfiguration, _ dataset: LineChartDataset) {
        self.akConfig = akConfig; self.dataset = dataset
        self.scale = CGSize(width: akConfig.xScale, height: akConfig.yScale)
    }
}

class LineChartMockDataSource: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map {
            CGPoint(x: Double($0) / 10, y: Double.random(in: 0..<1))
        }
    }
}

enum MockLineChartControls {
    static let akConfig = LineChartBrowsingSuccess()
    static let dataset = LineChartDataset(
        count: 4, constructor: { LineChartMockDataSource() }
    )

    static let controls = LineChartControls(akConfig, dataset)
}
