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

    weak var dataset: LineChartDataset?

    init(_ akConfig: LineChartConfiguration, _ dataset: LineChartDataset) {
        self.akConfig = akConfig; self.dataset = dataset
    }
}

class LineChartMockDataSource: LineChartLineDataProtocol {
    let xAxisMode: AxisMode
    let yAxisMode: AxisMode

    init(xAxisMode: AxisMode, yAxisMode: AxisMode) {
        self.xAxisMode = xAxisMode; self.yAxisMode = yAxisMode
    }

    func scaleToMode(value: CGFloat, mode: AxisMode) -> CGFloat {
        switch mode {
        // Not sure whether ln and log2 will ever be of any use
        case .amLinear: return CGFloat(value)
        case .amLog:    assert(false)//return exp(CGFloat(value))
        case .amLog2:   assert(false)//return pow(2, CGFloat(value))
        case .amLog10:  return pow(10, CGFloat(value))
        }
    }

    func getPlotPoints() -> [CGPoint] {
        (Int(0)..<Int(10)).map {
            CGPoint(x: CGFloat($0) / 10, y: CGFloat.random(in: 0..<1))
        }
    }
}

enum MockLineChartControls {
    static let akConfig = LineChartBrowsingSuccess()
    
    static let dataset = LineChartDataset(
        count: akConfig.legendoids.count,
        constructor: {
            LineChartMockDataSource(
                xAxisMode: akConfig.xAxisMode,
                yAxisMode: akConfig.yAxisMode
            )
        }
    )

    static let controls = LineChartControls(akConfig, dataset)
}
