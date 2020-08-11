import SwiftUI

struct LineChartTheChartView: View {
    @EnvironmentObject var lineChartControls: LineChartControls

    var body: some View {
        VStack {
            LineChartHeaderView()
                .padding(.top, 5)

            LineChartDataBackdrop()
                .padding(5)
                .background(Color.gray)
        }
    }
}

struct LineChartTheChartView_Previews: PreviewProvider {
    static var dataset = LineChartDataset()

    static var lineChartControls = LineChartControls(
        LineChartBrowsingSuccess(), dataset
    )

    static var timer: Timer?

    static func startViewTick() -> LineChartControls {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: update)
        return lineChartControls
    }

    static func update() {
        for line in dataset.lines {
            let L = Int.random(in: 0..<100)
            let M = Double.random(in: 0..<1)
            for _ in 0..<L { line.track(sample: M) }
        }

        lineChartControls.updateTrigger += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: update)
    }

    static var previews: some View {
        LineChartTheChartView().environmentObject(startViewTick())
    }
}
