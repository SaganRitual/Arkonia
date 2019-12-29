import SpriteKit

enum Debug {
    static let debugColorIsEnabled = true

    static func debugColor(
        _ thorax: SKSpriteNode, _ thoraxColor: SKColor,
        _ nose: SKSpriteNode, _ noseColor: SKColor
    ) {
        if !Debug.debugColorIsEnabled { return }
        thorax.color = thoraxColor
        nose.color = noseColor
    }

    static func debugColor(_ stepper: Stepper, _ thoraxColor: SKColor, _ noseColor: SKColor) {
        if !Debug.debugColorIsEnabled { return }
        stepper.sprite.color = thoraxColor
        stepper.nose.color = noseColor
    }

    static func dumpArkonDebug(_ name: String) {
        let steppers: [Stepper] = GriddleScene.arkonsPortal.children.compactMap {
            return ($0 as? SKSpriteNode)?.getStepper(require: false)
        }

        guard let stepper = steppers.first(where: { $0.name == name }) else {
            Log.L.write("Stepper \(name) not found", level: 60)
            return
        }

        Log.L.write("sd \(stepper.dispatch.scratch.debugReport)", level: 60)
    }

    static func reconstruct(_ name: String) {
        Log.L.write("reconstructing \(name)")
        let wp = Grid.dimensions.wGrid - 1, hp = Grid.dimensions.hGrid - 1
        for x in -wp...wp {
            for y in -hp...hp {
                guard let cell = GridCell.atIf(x, y) else { continue }
                if cell.cellDebugReport.first(where: { $0.contains(name) }) == nil { continue }
                Log.L.write("Found at \(cell.gridPosition): \(cell.cellDebugReport)")
            }
        }
    }

    static func writeDebug(_ toWrite: String, scratch: Scratchpad, level: Int? = nil) {
        if level != nil && level! >= Log.minimumLevel {
            scratch.debugReport.append("\n\(toWrite)")
        }
    }
}
