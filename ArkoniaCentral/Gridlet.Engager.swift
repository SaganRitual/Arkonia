import SpriteKit

extension Gridlet {

    func copy() -> GridletCopy {
        return Grid.shared.serialQueue.sync {  GridletCopy(from: self) }
    }

    func engage(owner: String, require: Bool) -> Engager? {
        var engager: Engager?

        Grid.shared.serialQueue.sync {
            if self.owner == nil {
                print("new engager")
                engager = Engager(owner, gridPosition); return }
            if require { fatalError() }
        }

        return engager
    }

    func engageBlock(of cGridlets: Int, transferFrom: Engager) -> Engager? {
        return Grid.shared.serialQueue.sync {
            transferFrom.eatBrains()
            return engageBlock_(of: cGridlets, owner: transferFrom.owner)
        }
    }

    func engageBlock(of cGridlets: Int, owner: String) -> Engager? {
        return Grid.shared.serialQueue.sync {
            engageBlock_(of: cGridlets, owner: owner)
        }
    }

    func engageBlock_(of cGridlets: Int, owner: String) -> Engager? {
        let gridPoints: [AKPoint] = (0..<cGridlets).map {
            self.getGridPointByIndex($0)
        }

        return Engager(owner, gridPoints)
    }

    class Engager {
        let gridletCopies: [GridletCopy?]
        var gridletFrom: GridletCopy?
        var gridletTo: GridletCopy?
        var isLive = true
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
                guard let gridlet = Gridlet.atIf($0) else { return nil }

                if gridlet.owner == nil { gridlet.owner = owner }
                return GridletCopy(from: gridlet)
            }
        }

        func deinit_(_ dispatch: Dispatch) {
            Grid.shared.serialQueue.sync { dispatch.gridletEngager = nil }
        }

        deinit {
            if isLive == false { return }
            print("engager deinit", self.owner)
            disengage_()
            leave_()
        }

        @discardableResult
        func eatBrains() -> GridletCopy {
            isLive = false
            return gridletCopies[0]!
        }
    }
}

extension Gridlet.Engager {
    func disengage(keep k: AKPoint? = nil, awaken: Bool = false) {
        Grid.shared.serialQueue.sync { disengage_(keep: k, awaken: awaken) }
    }

    func disengage_(keep k: AKPoint? = nil, awaken: Bool = false) {
        print("disengage_, keep", k ?? AKPoint.zero)

        let keep = k ?? AKPoint.zero
        for copy_ in gridletCopies.dropFirst() {

            guard let copy = copy_ else { continue }
            if k != nil && keep == copy.gridPosition { continue }

            let gridlet = Gridlet.at(copy.gridPosition)

            defer {
                gridlet.owner = nil
            }

            if awaken {
                guard let sprite = gridlet.sprite else { continue }
                guard let stepper = Stepper.getStepper(from: sprite, require: false)
                    else { continue }

                stepper.dispatch.shift()
            }
        }
    }

    func leave() {
        _ = Grid.shared.serialQueue.sync { leave_() }
    }

    @discardableResult
    private func leave_() -> (Gridlet.Contents, SKSpriteNode?)? {
        guard let fromCopy = gridletFrom else { fatalError() }
        if gridletTo == nil { fatalError() }

//        print("gf from", fromCopy.gridPosition, fromCopy.contents, fromCopy.sprite?.name ?? "<no sprite>",
//              toCopy.gridPosition, toCopy.contents, toCopy.sprite?.name ?? "<no sprite>")
        let gridletFrom = Gridlet.at(fromCopy.gridPosition)
//        print("cc", gridletFrom.gridPosition, toCopy.gridPosition)

//            print("sg41",
//                  fromCopy.sprite?.name ?? "<no sprite in fromCopy>", gridletFrom.sprite?.name ?? "<no sprite in fromGridlet>",
//                  toCopy.sprite?.name ?? "<no sprite in toCopy>", gridletTo?.sprite?.name ?? "<no sprite in toGridlet>"
//              )

        guard let sp = fromCopy.sprite else { fatalError() }
        Stepper.getStepper(from: sp, require: false)?.gridlet = nil

        gridletFrom.contents = .nothing
//            gridletFrom.owner = nil
        gridletFrom.sprite = nil

//            print("sg42",
//                  fromCopy.sprite?.name ?? "<no sprite in fromCopy>", gridletFrom.sprite?.name ?? "<no sprite in fromGridlet>",
//                  toCopy.sprite?.name ?? "<no sprite in toCopy>", gridletTo?.sprite?.name ?? "<no sprite in toGridlet>"
//              )

//        print("gf2 from", fromCopy.gridPosition, fromCopy.contents, fromCopy.sprite?.name ?? "<no sprite>",
//              toCopy.gridPosition, toCopy.contents, toCopy.sprite?.name ?? "<no sprite>")
        return (fromCopy.contents, fromCopy.sprite)
    }

    func move() {
        Grid.shared.serialQueue.sync { move_() }
    }

    func move_() {
//        print("move from", gridletFrom?.gridPosition ?? AKPoint.zero, "to", gridletTo?.gridPosition ?? AKPoint.zero)
        guard let (contents, sprite_) = leave_() else {
            print("dummy occupy")
            return
        }

//        guard let sud = sprite_?.userData else { fatalError() }
//        print(
//            "leave ",
//            contents, sprite_?.name ?? "<no sprite>",
//            (sud[sud.allKeys[0]] as? Stepper)?.name ?? "no stepper",
//            (sud[sud.allKeys[0]] is Manna) ? "manna" : "not manna")
        guard let sprite = sprite_ else { fatalError() }

//        print("occupy ", contents, sprite.name ?? "<no sprite>")
        occupy_(contents, sprite)
    }

    func occupy(_ contents: Gridlet.Contents, _ sprite: SKSpriteNode) {
        Grid.shared.serialQueue.sync { occupy_(contents, sprite) }
    }

    func occupy_(_ contents: Gridlet.Contents, _ sprite: SKSpriteNode) {
        guard let gt = gridletTo else { fatalError() }
        let gridlet = Gridlet.at(gt.gridPosition)

        print("occupy_ \(gridlet.gridPosition) with \(contents), oldOwner = \(gridlet.owner ?? "none?"), newOwner = \(self.owner)")

        switch contents {
        case .arkon:
//            print("o_ arkon")
            guard Stepper.getStepper(from: sprite) != nil
                else { fatalError() }

        case .manna:
//            print("o_ manna")
            guard Manna.getManna(from: sprite) != nil
                else { fatalError() }

        case .nothing: fatalError()
        }

//        print("sg5", gridlet.gridPosition, contents)
        gridlet.contents = contents
        gridlet.sprite = sprite
        gridlet.owner = self.owner
    }
}
