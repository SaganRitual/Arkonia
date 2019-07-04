import Foundation
import SpriteKit

struct NetGraphics {
    let background: SKSpriteNode
    let fullNeuronsHangar: SpriteHangarProtocol
    let halfNeuronsHangar: SpriteHangarProtocol
    let linesHangar: SpriteHangarProtocol
    let netDisplayGrid: NetDisplayGridProtocol

    func drawConnection(from start: CGPoint, to end: CGPoint) {
        let line = linesHangar.makeSprite()
        let textureLength: CGFloat = line.size.width
        let targetLength: CGFloat = start.distance(to: end)
        line.xScale = targetLength / textureLength
        line.yScale = 1

        line.zRotation = (end - start).theta
        line.position = start + ((end - start) / 2)
        line.color = .white
        line.colorBlendFactor = 1
        line.alpha = 0.5
        line.zPosition = 0
        background.zPosition = -1
        background.addChild(line)
    }

    func drawConnection(from start_: GridPoint, to end_: GridPoint) {
        let start = netDisplayGrid.getPosition(start_)
        let end = netDisplayGrid.getPosition(end_)
        drawConnection(from: start, to: end)
    }

    func drawNeuron(at gridPoint: GridPoint, layerRole: LayerRole) {
        let hangar: SpriteHangarProtocol = {
            switch layerRole {
            case .senseLayer:  return halfNeuronsHangar
            case .motorLayer:  return halfNeuronsHangar
            case .hiddenLayer: return fullNeuronsHangar
            }
        }()

        let sprite = hangar.makeSprite()

        let yFudge: CGFloat

        switch layerRole {
        case .senseLayer:
            sprite.color = .orange
            yFudge = sprite.size.height / 8

        case .motorLayer:
            sprite.color = .blue
            sprite.zRotation = CGFloat.pi
            yFudge = -sprite.size.height / 8

        case .hiddenLayer:
            sprite.color = .green
            yFudge = 0
        }

        sprite.setScale(0.1)
        sprite.colorBlendFactor = 0.5
        sprite.position = netDisplayGrid.getPosition(gridPoint)
        sprite.position.y -= yFudge
        sprite.zPosition = 2
        background.addChild(sprite)
    }
}

extension NetGraphics {
    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let dg = NetDisplayGrid()
        let fh = FullNeuronsHangar()
        let hh = HalfNeuronsHangar()
        let Lh = LinesHangar(view: scene.view!)

        let ng = NetGraphics(
            background: background,
            fullNeuronsHangar: fh, halfNeuronsHangar: hh, linesHangar: Lh,
            netDisplayGrid: dg
        )

        ng.drawNeuron(at: GridPoint(x: -1, y: +3), layerRole: .senseLayer)
        ng.drawNeuron(at: GridPoint(x: +1, y: +3), layerRole: .senseLayer)
        ng.drawNeuron(at: GridPoint(x: -2, y:  0), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x:  0, y:  0), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x: +2, y:  0), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x: -1, y: -3), layerRole: .motorLayer)
        ng.drawNeuron(at: GridPoint(x: +1, y: -3), layerRole: .motorLayer)

        ng.drawConnection(from: GridPoint(x: -1, y: +3), to: GridPoint(x: -2, y:  0))
        ng.drawConnection(from: GridPoint(x: +1, y: +3), to: GridPoint(x: +2, y:  0))
        ng.drawConnection(from: GridPoint(x: -2, y:  0), to: GridPoint(x:  0, y:  0))
        ng.drawConnection(from: GridPoint(x:  0, y:  0), to: GridPoint(x: +2, y:  0))
        ng.drawConnection(from: GridPoint(x: -1, y: -3), to: GridPoint(x: -2, y:  0))
        ng.drawConnection(from: GridPoint(x: +1, y: -3), to: GridPoint(x: +2, y:  0))
    }

    struct FullNeuronsHangar: SpriteHangarProtocol {
        func makeSprite() -> SKSpriteNode {
            return SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        }
    }

    struct HalfNeuronsHangar: SpriteHangarProtocol {
        func makeSprite() -> SKSpriteNode {
            return SKSpriteNode(color: .green, size: CGSize(width: 100, height: 100))
        }
    }

    struct LinesHangar: SpriteHangarProtocol {
        let texture: SKTexture

        init(view: SKView) {
            let linePath = CGMutablePath()

            linePath.move(to: CGPoint.zero)
            linePath.addLine(to: CGPoint(x: 100, y: 0))

            let line = SKShapeNode(path: linePath)

            texture = view.texture(from: line)!
        }

        func makeSprite() -> SKSpriteNode { return SKSpriteNode(texture: texture) }
    }

    struct NetDisplayGrid: NetDisplayGridProtocol {
        var layerRole: LayerRole {
            // swiftlint:disable unused_setter_value
            get { fatalError() } set { fatalError() }
            // swiftlint:enable unused_setter_value
        }

        func setHorizontalSpacing(cNeurons: Int, padRadius: CGFloat) {
            fatalError()
        }

        func getPosition(_ gridPosition: GridPoint) -> CGPoint {
            return CGPoint(x: gridPosition.x * 100, y: gridPosition.y * 100)
        }
    }
}
