import SpriteKit

struct NetGraphics {
    let background: SKSpriteNode
    let fullNeuronsHangar: SpriteHangar
    let halfNeuronsHangar: SpriteHangar
    let linesHangar: SpriteHangar
    let netDisplayGrid: NetDisplayGridProtocol

    func drawConnection(from start: CGPoint, to end: CGPoint, _ onComplete: @escaping SpriteFactoryCallback1P) {
        var line: SKSpriteNode!
        var textureLength: CGFloat = 0
        var targetLength: CGFloat = 0

        GriddleScene.shared.run(SKAction.run { partA() })

        func partA() { linesHangar.makeSprite("line", partB) }

        func partB(_ sprite: SKSpriteNode) {
            textureLength = line.size.width
            targetLength = start.distance(to: end)
            line.xScale = targetLength / textureLength
            line.yScale = 1

            line.zRotation = (end - start).theta
            line.position = start + ((end - start) / 2)
            line.color = .white
            line.colorBlendFactor = 1
            line.alpha = 0.5
            line.zPosition = 0
            background.zPosition = -1
            self.background.addChild(line)
            onComplete(line)
        }
    }

    func drawConnection(from start_: GridPoint, to end_: GridPoint, _ onComplete: @escaping SpriteFactoryCallback1P) {
        let start = netDisplayGrid.getPosition(start_)
        let end = netDisplayGrid.getPosition(end_)
        drawConnection(from: start, to: end, onComplete)
    }

    func drawNeuron(
        at gridPoint: GridPoint, layerRole: LayerRole, _ onComplete: @escaping SpriteFactoryCallback0P
    ) {
        let a = SKAction.run { self.drawNeuron(at: gridPoint, layerRole: layerRole) }
        GriddleScene.shared.run(a) { onComplete() }
    }

    func drawNeuron(at gridPoint: GridPoint, layerRole: LayerRole) {
        let hangar: SpriteHangar = {
            switch layerRole {
            case .senseLayer:  return halfNeuronsHangar
            case .motorLayer:  return halfNeuronsHangar
            case .hiddenLayer: return fullNeuronsHangar
            }
        }()

        let sprite: SKSpriteNode = hangar.makeSprite("neuron")

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
        sprite.alpha = 1.0
        sprite.position = netDisplayGrid.getPosition(gridPoint)
        sprite.position.y -= yFudge
        sprite.zPosition = 17

        self.background.addChild(sprite)

        Debug.log("sprite \(six(sprite.name)) at \(sprite.position)", level: 17)
    }
}
