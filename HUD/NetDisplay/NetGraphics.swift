import SpriteKit

struct NetGraphics {
    let fullNeuronsPortal: SKSpriteNode
    let halfNeuronsPortal: SKSpriteNode
    let netDisplayGrid: NetDisplayGridProtocol

    func drawConnection(from start: CGPoint, to end: CGPoint) {
        var textureLength: CGFloat = 0
        var targetLength: CGFloat = 0

        let line = SpriteFactory.shared.linesPool.makeSprite("line")
        textureLength = line.size.width
        targetLength = start.distance(to: end)
        line.xScale = targetLength / textureLength
        line.yScale = 1

        line.zRotation = (end - start).theta
        line.position = start + ((end - start) / 2)

        SpriteFactory.shared.linesPool.attachSprite(line)
    }

    func drawConnection(from start_: GridPoint, to end_: GridPoint, _ onComplete: @escaping () -> Void) {
        SceneDispatch.schedule {
            Debug.log(level: 102) { "drawConnection 1" }
            let start = self.netDisplayGrid.getPosition(start_)
            let end = self.netDisplayGrid.getPosition(end_)
            self.drawConnection(from: start, to: end)
            onComplete()
        }
    }

    func drawNeuron(at gridPoint: GridPoint, layerRole: LayerRole) {
        let portal: SKSpriteNode
        let sprite: SKSpriteNode
        let yFudge: CGFloat

        switch layerRole {
        case .senseLayer:
            portal = halfNeuronsPortal
            sprite = SpriteFactory.shared.halfNeuronsPool.makeSprite("neuron")
            sprite.color = .orange
            sprite.zRotation = 0
            sprite.setScale(1)    // Set the scale to get yFudge right, set real scale below
            yFudge = sprite.size.height / Arkonia.zoomFactor / 2

        case .motorLayer:
            portal = halfNeuronsPortal
            sprite = SpriteFactory.shared.halfNeuronsPool.makeSprite("neuron")
            sprite.color = .blue
            sprite.zRotation = CGFloat.pi
            sprite.setScale(1)    // Set the scale to get yFudge right, set real scale below
            yFudge = -sprite.size.height / Arkonia.zoomFactor / 2

        case .hiddenLayer:
            portal = fullNeuronsPortal
            sprite = SpriteFactory.shared.fullNeuronsPool.makeSprite("neuron")
            sprite.color = .green
            sprite.setScale(1)    // Set the scale to get yFudge right, set real scale below
            yFudge = 0
        }

        sprite.colorBlendFactor = 0.5
        sprite.alpha = 1.0
        sprite.position = netDisplayGrid.getPosition(gridPoint)
        sprite.position.y -= yFudge
        sprite.zPosition = 17
        sprite.setScale(0.1)

        portal.addChild(sprite)

        Debug.log("sprite \(six(sprite.name)) at \(sprite.position)", level: 17)
    }

    func drawNeuron(
        at gridPoint: GridPoint, layerRole: LayerRole, _ onComplete: @escaping () -> Void
    ) {
        SceneDispatch.schedule {
            Debug.log(level: 102) { "drawNeuron" }
            self.drawNeuron(at: gridPoint, layerRole: layerRole)
            onComplete()
        }
    }
}
