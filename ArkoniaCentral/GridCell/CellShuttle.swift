import SpriteKit

class CellShuttle {
    var consumedContents = GridCell.Contents.nothing
    weak var consumedSprite: SKSpriteNode?
    var didMove = false
    var fromCell: HotKey?
    var toCell: HotKey?

    init(_ fromCell: HotKey?, _ toCell: HotKey) {
        self.fromCell = fromCell; self.toCell = toCell
    }

    func move() {
        consumedContents = .nothing
        consumedSprite = nil

        // No fromCell means we didn't move
        guard let f = fromCell else { return }
        guard let t = toCell else { preconditionFailure() }

        consumedContents = t.contents
        consumedSprite = t.sprite

        if consumedContents.isEdible() { Log.L.write("consumedContents1 = \(consumedContents), sprite = \(six(consumedSprite?.name)), at \((consumedSprite?.position ?? CGPoint.zero) / 32)", level: 55) }

        let gp = (t.contents == .arkon) ? ", grid position \(t.sprite!.getStepper(require: true)!.gridCell!)" : ""
        let sp = (t.contents == .arkon) ? ", scene position \(t.sprite!.getStepper(require: true)!.gridCell!.scenePosition)" : ""
        let pp = (t.contents == .arkon) ? ", sprite position \(t.sprite!.position)" : ""
        if !(gp + sp + pp).isEmpty { Log.L.write("gp \(gp)/\(sp)/\(pp)", level: 56) }
        Log.L.write("Shuttleing from \(six(f.ownerName))/\(six(f.sprite?.name)) at \(f.gridPosition)/\(f.scenePosition) to \(six(t.ownerName)) at \(t.gridPosition), consuming \(t.contents)\(gp)/\(sp)/\(pp)", level: 56)

        Log.L.write("Shuttleing2 from \(six(f.ownerName))/\(six(f.sprite?.name)) at \(f.gridPosition)/\(f.scenePosition) to \(six(t.ownerName)) at \(t.gridPosition), consuming \(t.contents)\(gp)/\(sp)/\(pp)", level: 56)

        if consumedContents == .arkon {
            Log.L.write(
                "consumedContents2 = \(consumedContents), " +
                "sprite = \(six(consumedSprite?.name))/\(six(consumedSprite?.getStepper(require: false)?.name)), " +
                "at \((consumedSprite?.position ?? CGPoint.zero) / 32)" +
                "f \(f.contents), \(six(f.sprite?.name)), \((f.sprite?.position ?? CGPoint.zero) / 32)"
                , level: 57) }

        t.contents = f.contents
        t.sprite = f.sprite

        f.contents = .nothing
        f.sprite = nil

        didMove = true

        let ruspect1 = t.sprite?.getStepper(require: false)?.gridCell.gridPosition ?? AKPoint.zero
        let ruspect2 = f.sprite?.getStepper(require: false)?.gridCell.gridPosition ?? AKPoint.zero
        let eiff = ruspect2 - ruspect1
        if (abs(eiff.x) > 1 || abs(eiff.y) > 1) && ruspect1 != AKPoint.zero && ruspect2 != AKPoint.zero {
            Log.L.write("there")
        }

    }

    func transferKeys(to winner: Stepper) -> CellShuttle {
        toCell?.transferKey(to: winner)
        fromCell?.transferKey(to: winner)
        return self
    }
}
