import Foundation
import SpriteKit

class LineGraphFactory {
    private let prototype: LineGraph
    static var dotTexture: SKTexture!

    init(hud: HUD, scene: KarambaScene) {
        prototype = hardBind(hud.getPrototype(.linegraph) as? LineGraph)
        let tShape = SKShapeNode(circleOfRadius: 2.5)
        LineGraphFactory.dotTexture = scene.view?.texture(from: tShape)

        hud.releasePrototype(prototype)
    }

    func newGraph() -> LineGraph { return hardBind(prototype.copy() as? LineGraph) }
}

struct LineGraphTriplet {
    let average: CGFloat
    let median: CGFloat
    let sum: CGFloat
}

enum Plot: String, CaseIterable { case average, median, sum }

final class LineGraph: SKSpriteNode {
    static let tripletsCount = 10
    static let plotNamePrefix = "line_graph_plot_"

    var canvas: SKSpriteNode?
    var bottom: CGFloat = 0
    var maxInput: CGFloat = 100.0
    let minInput: CGFloat = 0.0
    let minusOne = (LineGraph.tripletsCount - 1) % LineGraph.tripletsCount
    var nextPut = 0
    var pullDataAction: SKAction?
    var started = false
    var triplets = IndexedRingBuffer<LineGraphTriplet>(size: tripletsCount)

    static func drawLine(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)
        line.strokeColor = color
        line.lineWidth = 3
        return line
    }

    func start() {
        canvas = childNode(withName: "linegraph_canvas") as? SKSpriteNode
        let c = hardBind(canvas)
        bottom = c.position.y - c.size.height / 2

        for exponent in stride(from: 0, through: log10(maxInput), by: 1) {
            let heightInput = pow(10, exponent)
            let y = logPlotY(heightInput)
            let line = LineGraph.drawLine(
                from: CGPoint(x: -size.width / 2, y: y),
                to: CGPoint(x: size.width / 2, y: y),
                color: .black
            )

            line.zPosition = hardBind(canvas).zPosition + 0.1
            addChild(line)
        }

        let delayAction = SKAction.wait(forDuration: 0.47)
        let updateAction = SKAction.run { [weak self] in self?.update() }
        let updateSequence = SKAction.sequence([delayAction, pullDataAction!, updateAction])
        let updateForever = SKAction.repeatForever(updateSequence)

        let toChildren: [SKAction] = (0..<LineGraph.tripletsCount).map {
            let nextPlot = ($0 + 1) % LineGraph.tripletsCount

            let plotAverage = SKAction.moveTo(y: bottom, duration: 0.25)
            let averageName = hardBind(dot(nextPlot, .average).name)
            let toAverageDot = SKAction.run(plotAverage, onChildWithName: averageName)

            let plotMedian = SKAction.moveTo(y: bottom, duration: 0.25)
            let medianName = hardBind(dot(nextPlot, .median).name)
            let toMedianDot = SKAction.run(plotMedian, onChildWithName: medianName)

            let plotSum = SKAction.moveTo(y: bottom, duration: 0.25)
            let sumName = hardBind(dot(nextPlot, .sum).name)
            let toSumDot = SKAction.run(plotSum, onChildWithName: sumName)

            return SKAction.group([toAverageDot, toMedianDot, toSumDot])
        }

        let dazzle = SKAction.group(toChildren)
        let fly = SKAction.sequence([dazzle, updateForever])

        run(fly)
    }

    func logPlotY(_ input_: CGFloat) -> CGFloat {
        precondition(input_ >= minInput)

        let input = min(input_, 100)
        let can = hardBind(canvas)
        let heightOfChart: CGFloat = can.size.height
        let bottomOfChart: CGFloat = can.position.y - heightOfChart / 2

        let nz = (input == 0) ? 1 : input + 1
        let nonZero = CGFloat(log10(nz))
        let minLog: CGFloat = log10(minInput + 1.0)
        let maxLog: CGFloat = log10(maxInput + 1.0)

        let output = bottomOfChart + heightOfChart * (nonZero - minLog) / (maxLog - minLog)
        return output
    }

    func update() {
        for offset in 0..<LineGraph.tripletsCount {
            guard let triplet = triplets.get(at: nextPut + offset) else { continue }

            dot(offset, .average).position.y = logPlotY(triplet.average)
            dot(offset, .median).position.y =  logPlotY(triplet.median)
            dot(offset, .sum).position.y =     logPlotY(triplet.sum)
        }

        marchLines()
    }
}

// MARK: Lines

extension LineGraph {
    func dot(_ ss: Int, _ plot: Plot) -> SKSpriteNode {
        let namePrefixWithColumn = LineGraph.plotNamePrefix + String(format: "%02d_", ss)
        let dotName = namePrefixWithColumn + plot.rawValue
        let dot = childNode(withName: dotName)
        return hardBind(dot as? SKSpriteNode)
    }

    func dotsDo(_ ss: Int, _ distribute: (SKSpriteNode) -> Void) {
        for plot in Plot.allCases {
            let theDot = dot(ss, plot)
            distribute(theDot)
        }
    }

    func dotsDos(_ lSS: Int, _ distribute: (SKSpriteNode, SKSpriteNode) -> Void) {
        for plot in Plot.allCases {
            let lhs = dot(lSS, plot)
            let rhs = dot(lSS + 1, plot)
            distribute(lhs, rhs)
        }
    }

    func drawLines(from offset: Int) {
        dotsDos(offset) { lhs, rhs in
            let LP = self.convert(lhs.position, to: lhs)
            let RP = self.convert(rhs.position, to: lhs)
            let line = LineGraph.drawLine(from: LP, to: RP, color: lhs.color)
            lhs.addChild(line)
        }
    }

    func marchLines() {
        dotsDo(0) { $0.removeAllChildren() }

        for offset in 0..<(LineGraph.tripletsCount - 2) {
            if triplets.get(at: nextPut + offset + 1) == nil { continue }

            dotsDos(offset) { lhs, rhs in
                if rhs.children.isEmpty { return }
                let line = rhs.children[0]
                line.removeFromParent()
                lhs.addChild(line)
            }
        }

        drawLines(from: LineGraph.tripletsCount - 2)
    }
}

// MARK: Setup chart components

extension LineGraph {

    func addSamples(average: CGFloat, median: CGFloat, sum: CGFloat) {
        if !started { start(); started = true }

//        if average > 1000 {
//            print("here")
//        }
        triplets.put(
            value: LineGraphTriplet(average: average, median: median, sum: sum), at: nextPut
        )

        nextPut += 1
    }

    func setChartLabel(_ text: String) {
        let lineGraphLabel = "linegraph_title"
        let node = childNode(withName: lineGraphLabel)
        let label = hardBind(node as? SKLabelNode)
        label.text = text
    }

}
