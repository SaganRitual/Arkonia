import SpriteKit

extension Gridlet {

    func copy() -> GridletCopy {
        return Grid.shared.serialQueue.sync {  GridletCopy(from: self) }
    }

    func engage(owner: String, require: Bool) -> Engager? {
        var engager: Engager?

        Grid.shared.serialQueue.sync {
            if self.owner == nil { engager = Engager(owner, gridPosition); return }
            if require { fatalError() }
        }

        return engager
    }

    func engageBlock(of cGridlets: Int, owner: String) -> Engager? {
        var engager: Engager?

        Grid.shared.serialQueue.sync {
            let gridPoints: [AKPoint] = (0..<cGridlets).map {
                self.getGridPointByIndex($0)
            }

            engager = Engager(owner, gridPoints)
        }

        return engager
    }

    class Engager {
        let gridletCopies: [GridletCopy]
        var gridletFrom: GridletCopy?
        var gridletTo: GridletCopy?
        let owner: String

        fileprivate init(_ owner: String, _ position: AKPoint) {
            let gridlet = Gridlet.at(position)
            gridlet.owner = owner
            self.owner = owner

            self.gridletCopies = [GridletCopy(from: gridlet)]
        }

        fileprivate init(_ owner: String, _ positions: [AKPoint]) {
            self.owner = owner

            gridletCopies = positions.map {
                let gridlet = Gridlet.at($0)
                if gridlet.owner == nil { gridlet.owner = owner }
                return GridletCopy(from: gridlet)
            }
        }

        deinit { disengage() }
    }
}

extension Gridlet.Engager {
    func disengage(keep k: AKPoint? = nil) {
        Grid.shared.serialQueue.sync {

            let keep = k ?? AKPoint.zero
            for copy in gridletCopies.dropFirst() where keep != copy.gridPosition {
                let gridlet = Gridlet.at(copy.gridPosition)
                gridlet.owner = nil
            }

            guard let gt = k else { return }
            gridletFrom = gridletCopies[0]
            gridletTo = GridletCopy(from: Gridlet.at(gt))
        }
    }

    func leave() {
        _ = Grid.shared.serialQueue.sync { leave_() }
    }

    @discardableResult
    private func leave_() -> (Gridlet.Contents, SKSpriteNode?) {
        guard let gf = gridletFrom else { fatalError() }
        let gridlet = Gridlet.at(gf.gridPosition)

        guard gridlet.owner ?? "not a real owner name" == self.owner
            else { fatalError() }

        defer {
            gridlet.contents = .nothing
            gridlet.sprite = nil
        }

        return (gridlet.contents, gridlet.sprite)
    }

    func move() {
        Grid.shared.serialQueue.sync {
            let (contents, sprite_) = leave_()
            guard let sprite = sprite_ else { fatalError() }

            occupy_(contents, sprite)
        }
    }

    func occupy(_ contents: Gridlet.Contents, _ sprite: SKSpriteNode) {
        Grid.shared.serialQueue.sync { occupy_(contents, sprite) }
    }

    func occupy_(_ contents: Gridlet.Contents, _ sprite: SKSpriteNode) {
        guard let gt = gridletTo else { fatalError() }
        let gridlet = Gridlet.at(gt.gridPosition)

        guard gridlet.owner ?? "not a real owner name" == self.owner
            else { fatalError() }

        switch contents {
        case .arkon:
            guard Stepper.getStepper(from: sprite) != nil
                else { fatalError() }

        case .manna:
            guard Manna.getManna(from: sprite) != nil
                else { fatalError() }

        case .nothing: fatalError()
        }

        gridlet.contents = contents
        gridlet.sprite = sprite
    }
}
