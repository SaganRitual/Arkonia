import Foundation
import SpriteKit

class LineGraphFactory {
    private let prototype: LineGraph
    static var dotTexture: SKTexture!

    init(hud: HUD, scene: ArkoniaScene) {
        guard let p = hud.getMonitorPrototype(.linegraph, from: hud.dashboards[0]) as? LineGraph else { fatalError() }
        prototype = p
        let tShape = SKShapeNode(circleOfRadius: 2.5)
        LineGraphFactory.dotTexture = scene.view?.texture(from: tShape)

        hud.releasePrototype(prototype)
    }

    func newGraph() -> LineGraph { return (prototype.copy() as? LineGraph)! }
}

enum LineGraphSetId: Int, CaseIterable { case avg, med, max }

class LineGraphPlotSet {
    let avg: SKSpriteNode
    let med: SKSpriteNode
    let max: SKSpriteNode

    internal init(_ avg: SKSpriteNode, _ med: SKSpriteNode, _ max: SKSpriteNode) {
        self.avg = avg
        self.med = med
        self.max = max
    }

    func getLine(_ id: LineGraphSetId) -> SKSpriteNode {
        switch id {
        case .avg: return avg
        case .med: return med
        case .max: return max
        }
    }
}

class LineGraphInputSet {
    var avg: CGFloat
    var med: CGFloat
    var max: CGFloat

    internal init(_ avg: CGFloat = 0, _ med: CGFloat = 0, _ max: CGFloat = 0) {
        self.avg = avg
        self.med = med
        self.max = max
    }

    func getInput(_ id: LineGraphSetId) -> CGFloat {
        switch id {
        case .avg: return avg
        case .med: return med
        case .max: return max
        }
    }
}

enum Plot: String, CaseIterable { case avg, med, max }

final class LineGraph: SKSpriteNode {
    static let cSamplesForAverage = 5
    static let cColumns = 75
    static let plotNamePrefix = "line_graph_plot_"

    var bottom: CGFloat = 0
    var canvases = [SKSpriteNode]()
    var columnWidth = 0
    var cropNode: SKCropNode!
    var currentColumn = 0
    var maskNode: SKSpriteNode!
    var maxInput: CGFloat = 10000.0
    let minInput: CGFloat = 0.0
    var plotSets = [LineGraphPlotSet]()
    var runningAverages = Cbuffer<LineGraphInputSet>(cElements: LineGraph.cSamplesForAverage, mode: .putOnlyRing)
    var started = false

    func setChartLabel(_ text: String) {
        let lineGraphLabel = "linegraph_title_understudy"
        let node = childNode(withName: lineGraphLabel)
        let label = (node as? SKLabelNode)!
        label.text = text
    }

    func start() {
        self.enumerateChildNodes(withName: "linegraph_canvas*") { cn, _ in
            guard let canvasNode = cn as? SKSpriteNode else { fatalError() }
            self.canvases.append(canvasNode)
        }

        // Need two canvas shapes to get the conveyor belt effect
        assert(self.canvases.count == 2)

        self.maskNode = (self.canvases[0].copy() as? SKSpriteNode)!
        self.maskNode.name = "masknode"
        self.maskNode.color = .yellow

        self.cropNode = SKCropNode()
        self.cropNode.name = "cropnode"
        self.cropNode.maskNode = self.maskNode
        self.addChild(self.cropNode)

        bottom = self.cropNode.position.y - self.maskNode.size.height / 2

        columnWidth = Int(maskNode.size.width) / LineGraph.cColumns

        drawYAxisMarkers()
        setupGraphLines()

        let moveVector = CGVector(dx: -self.canvases[0].size.width, dy: 0)

        let slideAction =    SKAction.move(by: moveVector, duration: TimeInterval(LineGraph.cColumns))
        let hideAction =     SKAction.fadeOut(withDuration: 0)
        let unslideAction =  SKAction.move(by: -2 * moveVector, duration: 0)
        let unhideAction =   SKAction.fadeIn(withDuration: 0)

        let c0Sequence = [slideAction, hideAction, unslideAction, unhideAction, slideAction]
        let c1Sequence = [slideAction, slideAction, hideAction, unslideAction, unhideAction]
        let slideSequences = [c0Sequence, c1Sequence]

        let waitAction = SKAction.wait(forDuration: 1)
        let updateAction = SKAction.run { self.update() }
        let updateSequence = [updateAction, waitAction]
        let updateSequenceAction = SKAction.sequence(updateSequence)

        zip(canvases, slideSequences).forEach { canvas, slideSequence in
            canvas.removeFromParent()
            self.cropNode.addChild(canvas)

            let slideSequenceAction = SKAction.sequence(slideSequence)
            let forever = SKAction.repeatForever(slideSequenceAction)

            canvas.run(forever)
        }

        let updateForever = SKAction.repeatForever(updateSequenceAction)
        run(updateForever)
    }

    func drawYAxisMarkers() {
        for exponent in stride(from: 0, through: log10(maxInput), by: 1) {
            let heightInput = pow(10, exponent)
            let y = logPlotY(heightInput)

            self.canvases.forEach { canvas in
                let line = SpriteFactory.drawLine(
                    from: CGPoint(x: -size.width / 2, y: y),
                    to: CGPoint(x: size.width / 2, y: y),
                    color: .gray
                )

                line.lineWidth = 0.1
                line.zPosition = canvas.zPosition + 0.1
                addChild(line)
            }
        }
    }

    func logPlotY(_ input_: CGFloat) -> CGFloat {
        precondition(input_ >= minInput)

        let input = min(input_, maxInput)
        let heightOfChart: CGFloat = canvases[0].size.height
        let bottomOfChart: CGFloat = canvases[0].position.y - heightOfChart / 2

        let nz = (input == 0) ? 1 : input + 1
        let nonZero = CGFloat(log10(nz))
        let minLog: CGFloat = log10(minInput + 1.0)
        let maxLog: CGFloat = log10(maxInput + 1.0)

        let output = bottomOfChart + heightOfChart * (nonZero - minLog) / (maxLog - minLog)
        return output
    }

    func setupGraphLines() {
        self.plotSets = (0..<LineGraph.cColumns * 2).map { ss in
            let avg = SpriteFactory.shared.dotsPool.getDrone()
            let med = SpriteFactory.shared.dotsPool.getDrone()
            let max = SpriteFactory.shared.dotsPool.getDrone()

            let whichCanvas = (ss < LineGraph.cColumns) ? 0 : 1

            [avg, med, max].forEach {
                canvases[whichCanvas].addChild($0)

                let xHideDots = 1 // Hide outside crop window until after update
                let xAdjust = (LineGraph.cColumns / 2) - xHideDots
                let cAdjust = ss - (whichCanvas * LineGraph.cColumns)
                $0.position = CGPoint(x: CGFloat((cAdjust - xAdjust) * columnWidth), y: self.bottom)

                $0.setScale(0.25 / Arkonia.zoomFactor)
                $0.alpha = 1
                $0.colorBlendFactor = 1
            }

            avg.color = .orange; med.color = .green; max.color = .magenta

            return LineGraphPlotSet(avg, med, max)
        }

        currentColumn = LineGraph.cColumns
    }

    func update() {
        func a() { LineGraphUpdate.getAgeStats(b) }

        func b(_ newInputSet_: LineGraphInputSet?) {
            defer {
                currentColumn = (currentColumn + 1) % (LineGraph.cColumns * 2)
            }

            guard let newInputSet = newInputSet_ else { return }

            runningAverages.put(newInputSet)

            LineGraphSetId.allCases.forEach { whichDatum in
                let total = runningAverages.elements.reduce(CGFloat.zero) { subtotal, inputSet_ in
                    guard let inputSet = inputSet_ else { fatalError() }
                    return subtotal + inputSet.getInput(whichDatum)
                }

                let average = total / CGFloat(runningAverages.count)
                let rawSample = newInputSet.getInput(whichDatum)
                let final = (whichDatum == .max) ? rawSample : average

                let plotY = logPlotY(final)
                let plotoid = plotSets[currentColumn].getLine(whichDatum)

                plotoid.position.y = plotY
            }
        }

        a()
    }
}
