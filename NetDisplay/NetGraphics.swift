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

        sprite.setScale(0.2)
        sprite.colorBlendFactor = 0.5
        sprite.alpha = 1.0
        sprite.position = netDisplayGrid.getPosition(gridPoint)
        sprite.position.y -= yFudge
        sprite.zPosition = 17
        background.addChild(sprite)
        Log.L.write("sprite \(six(sprite.name)) at \(sprite.position)", level: 17)
    }
}
