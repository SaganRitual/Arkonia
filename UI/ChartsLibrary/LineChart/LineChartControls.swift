import SwiftUI

protocol LineChartLineDataProtocol: class {
    func getPlotPoints() -> (CGFloat, [CGPoint])
}

class LineChartDataset: ObservableObject {
    @Published var xAxisTopBaseValue: CGFloat = 100
    @Published var xAxisTopExponentValue: CGFloat = 0
    @Published var yAxisTopBaseValue: CGFloat = 10
    @Published var yAxisTopExponentValue: CGFloat = 1

    let lines: [LineChartLineDataProtocol]

    init(count: Int, constructor: () -> LineChartLineDataProtocol) {
        self.lines = (0..<count).map { _ in constructor() }
    }

    func update(_ xBase: CGFloat, _ xExp: CGFloat, _ yBase: CGFloat, _ yExp: CGFloat) {
        print("lcd update \(xBase), \(xExp), \(yBase), \(yExp)")
        xAxisTopBaseValue = xBase
        xAxisTopExponentValue = xExp
        yAxisTopBaseValue = yBase
        yAxisTopExponentValue = yExp
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

    var xAxisTopBaseValue: CGFloat = 100
    var xAxisTopExponentValue: CGFloat = 0
    var yAxisTopBaseValue: CGFloat = 10
    var yAxisTopExponentValue: CGFloat = 1

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

    func getPlotPoints() -> (CGFloat, [CGPoint]) {
        print("getpltpoints2")
        return (
            0,
            (Int(0)..<Int(10)).map { CGPoint(x: CGFloat($0) / 10, y: CGFloat.random(in: 0..<1)) }
        )
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
