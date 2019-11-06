import SpriteKit

typealias GridletSet = (Gridlet.Contents, SKSpriteNode) -> Void

extension Gridlet {
    func connect(sprite: SKSpriteNode, result: @escaping Connector.Result) {
        var connector: Connector?

        let wiInit = DispatchWorkItem(flags: .barrier) { [unowned self] in
            if self.gridletIsEngaged { result(nil); return }
            connector = Connector(sprite, to: self)
        }

        Grid.shared.concurrentQueue.async(execute: wiInit)
        wiInit.notify(queue: Grid.shared.concurrentQueue) { result(connector) }
    }

    func engage(require: Bool) -> Engager? {
        var engager: Engager?

        Grid.shared.serialQueue.sync {
            if !self.gridletIsEngaged { engager = Engager(self) }
            if require { fatalError() }
        }

        return engager
    }

    class Engager {
        //swiftlint:disable nesting
        typealias Result = (Engager?) -> Void
        //swiftlint:enable nesting

        weak var gridlet: Gridlet?

        init(_ gridlet: Gridlet) {
            gridlet.gridletIsEngaged = true
            self.gridlet = gridlet
        }

        deinit {
            Grid.shared.serialQueue.sync {
                guard let g = self.gridlet else { fatalError() }
                g.gridletIsEngaged = false
            }
        }

        func disengage() {
            Grid.shared.serialQueue.sync {
                guard let g = gridlet else { fatalError() }
                guard g.gridletIsEngaged else { fatalError() }
                g.gridletIsEngaged = false
            }
        }

        func enter(_ contents: Gridlet.Contents, _ sprite: SKSpriteNode) {
            Grid.shared.serialQueue.sync {
                guard let g = gridlet else { fatalError() }
                guard g.gridletIsEngaged else { fatalError() }

                switch contents {
                case .arkon:
                    guard Stepper.getStepper(from: sprite) != nil
                        else { fatalError() }

                case .manna:
                    guard Manna.getManna(from: sprite) != nil
                        else { fatalError() }

                case .nothing: fatalError()
                }

                g.contents = contents
                g.sprite = sprite
            }
        }

        func leave() {
            Grid.shared.serialQueue.sync {
                guard let g = gridlet else { fatalError() }
                guard g.gridletIsEngaged else { fatalError() }

                g.contents = .nothing
                g.sprite = nil
            }
        }
    }

    class Connector {
        //swiftlint:disable nesting
        typealias Result = (Connector?) -> Void
        //swiftlint:enable nesting

        fileprivate weak var gridlet: Gridlet?
        fileprivate var parked = false

        fileprivate init(_ sprite: SKSpriteNode, to gridlet: Gridlet) {
            self.gridlet = gridlet
            self.pReassign(to: sprite)
        }

        deinit {
            print("deinit")
            shift() }

        func park() {
            let wiPark = DispatchWorkItem(flags: .barrier) { [unowned self] in
                self.pPark()
            }

            Grid.shared.concurrentQueue.async(execute: wiPark)
        }

        func shift() {
            let wiShift = DispatchWorkItem(flags: .barrier) { [unowned self] in
                self.pShift(parked: self.parked)
            }

            Grid.shared.concurrentQueue.async(execute: wiShift)
        }
    }
}

extension Gridlet.Connector {
    func pPark() { pShift(parked: true) }

    func pReassign(to sprite: SKSpriteNode) {
        guard let g = gridlet else { fatalError() }
        g.sprite = sprite

        guard let userData = sprite.userData else { fatalError() }

        if userData[SpriteUserDataKey.stepper] != nil {
            g.contents = .arkon
        } else if userData[SpriteUserDataKey.manna] != nil {
            g.contents = .manna
        } else {
            fatalError()
        }
    }

    func pShift(parked: Bool) {
        gridlet?.gridletIsEngaged = false

        if !parked {
            gridlet?.sprite = nil
            gridlet?.contents = .nothing
        }
    }
}
