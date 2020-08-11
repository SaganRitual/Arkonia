import SwiftUI

class LineChartDataset: ObservableObject {
    let lines: [Histogram] = (0..<6).map { _ in Histogram(10, .zeroToVariable) }
}

class LineChartControls: ObservableObject {
    @Published var switches = [Bool](repeating: true, count: 6)

    let akConfig: LineChartConfiguration
    let scale = CGSize(width: ArkoniaLayout.xScale, height: ArkoniaLayout.yScale)

    weak var dataset: LineChartDataset?

    let legendoidPositions = [
        AKPoint(x: 0, y: 0), AKPoint(x: 0, y: 1), AKPoint(x: 0, y: 2),
        AKPoint(x: 1, y: 0), AKPoint(x: 1, y: 1), AKPoint(x: 1, y: 2)
    ]

    lazy var liveLegendoidPositions: [AKPoint] = {
        getLiveLegendoidPositions(AKPoint(x: 0, y: 0)) +
        getLiveLegendoidPositions(AKPoint(x: 1, y: 0))
    }()

    init(_ akConfig: LineChartConfiguration, _ dataset: LineChartDataset) {
        self.akConfig = akConfig; self.dataset = dataset
    }

    func getLegendoidSS(at chartPosition: AKPoint) -> Int {
        legendoidPositions.firstIndex(where: { $0 == chartPosition })!
    }

    func getLegendoidSwitch(at chartPosition: AKPoint) -> Bool {
        self.switches[getLegendoidSS(at: chartPosition)]
    }

    func getHistogram(at chartPosition: AKPoint) -> Histogram {
        self.dataset!.lines[getLegendoidSS(at: chartPosition)]
    }

    private func getLiveLegendoidPositions(_ side: AKPoint) -> [AKPoint] {
        return legendoidPositions.compactMap {
            if $0.x != side.x { return nil }
            return akConfig.getLegendoid(at: $0) == nil ? nil : $0
        }
    }
}
