import SwiftUI

protocol LineChartDatasetProtocol {

}

class LineChartDataset {
    let lines: [LineChartDatasetProtocol]

    init(count: Int, constructor: () -> LineChartDatasetProtocol) {
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
        self.scale = CGSize(width: akConfig..xScale, height: ArkoniaLayout.yScale)
    }

    func getHistogram(_ switchSS: Int) -> Histogram { self.dataset!.lines[switchSS] }
}
