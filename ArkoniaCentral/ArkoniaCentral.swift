import SpriteKit

enum ArkoniaCentral {
    static let masterScale = CGFloat(2)
    static let senseGridSide = 3
    static let spriteScale = masterScale / 6
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeurons = 2 * cSenseGridlets + 4
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1
    static let debugColorIsEnabled = true
}

func debugColor(
    _ thorax: SKSpriteNode, _ thoraxColor: SKColor,
    _ nose: SKSpriteNode, _ noseColor: SKColor
) {
    if !ArkoniaCentral.debugColorIsEnabled { return }
    thorax.color = thoraxColor
    nose.color = noseColor
}

func debugColor(_ stepper: Stepper, _ thoraxColor: SKColor, _ noseColor: SKColor) {
    if !ArkoniaCentral.debugColorIsEnabled { return }
    stepper.sprite.color = thoraxColor
    stepper.nose.color = noseColor
}

func dumpArkonDebug(_ name: String) {
    let steppers: [Stepper] = GriddleScene.arkonsPortal.children.compactMap {
        return ($0 as? SKSpriteNode)?.getStepper(require: false)
    }

    guard let stepper = steppers.first(where: { $0.name == name }) else {
        Log.L.write("Stepper \(name) not found", level: 60)
        return
    }

    Log.L.write("sd \(stepper.dispatch.scratch.debugReport)", level: 60)
}

func reconstruct(_ name: String) {
    Log.L.write("reconstructing \(name)")
    let wp = Grid.dimensions.wGrid - 1, hp = Grid.dimensions.hGrid - 1
    for x in -wp...wp {
        for y in -hp...hp {
            guard let cell = GridCell.atIf(x, y) else { continue }
            if cell.debugReport.first(where: { $0.contains(name) }) == nil { continue }
            Log.L.write("Found at \(cell.gridPosition): \(cell.debugReport)")
        }
    }
}
