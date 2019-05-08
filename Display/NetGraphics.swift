import Foundation
import SpriteKit

struct NetGraphics {
    let background: SKSpriteNode
    let fullNeuronsHangar: SpriteHangarProtocol
    let halfNeuronsHangar: SpriteHangarProtocol
    let linesHangar: SpriteHangarProtocol
    let netDisplayGrid: NetDisplayGridProtocol

    func drawConnection(from start_: GridPoint, to end_: GridPoint) {
        let start = netDisplayGrid.getPosition(start_)
        let end = netDisplayGrid.getPosition(end_)

        let line = linesHangar.makeSprite()
        let textureLength: CGFloat = line.size.width
        let targetLength: CGFloat = start.distance(to: end)
        line.xScale = targetLength / textureLength
        line.yScale = 3

        line.zRotation = (end - start).theta
        line.position = start + ((end - start) / 2)
        line.color = .red
        line.colorBlendFactor = 1
        background.addChild(line)
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

        switch layerRole {
        case .senseLayer: sprite.color =  .orange
        case .motorLayer: sprite.color =  .blue
        case .hiddenLayer: sprite.color = .green
        }

        sprite.position = netDisplayGrid.getPosition(gridPoint)
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

        ng.drawNeuron(at: GridPoint(x: -3, y: +1), layerRole: .senseLayer)
        ng.drawNeuron(at: GridPoint(x: -2, y: -1), layerRole: .senseLayer)
        ng.drawNeuron(at: GridPoint(x: -1, y: +1), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x:  0, y:  0), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x: +1, y: +1), layerRole: .hiddenLayer)
        ng.drawNeuron(at: GridPoint(x: +2, y: -1), layerRole: .motorLayer)
        ng.drawNeuron(at: GridPoint(x: +3, y: +1), layerRole: .motorLayer)

        ng.drawConnection(from: GridPoint(x: -3, y: +1), to: GridPoint(x: -2, y: -1))
        ng.drawConnection(from: GridPoint(x: -2, y: -1), to: GridPoint(x: -1, y: +1))
        ng.drawConnection(from: GridPoint(x: -1, y: +1), to: GridPoint(x:  0, y:  0))
        ng.drawConnection(from: GridPoint(x:  0, y:  0), to: GridPoint(x: +1, y: +1))
        ng.drawConnection(from: GridPoint(x: +1, y: +1), to: GridPoint(x: +2, y: -1))
        ng.drawConnection(from: GridPoint(x: +2, y: -1), to: GridPoint(x: +3, y: +1))
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
        func getPosition(_ gridPosition: GridPoint) -> CGPoint {
            return CGPoint(x: gridPosition.x * 100, y: gridPosition.y * 100)
        }
    }
}
