import SpriteKit

protocol TickStateProtocol: class {
    var core: Arkon { get }
    var metabolism: Metabolism { get }
    var sprite: SKSpriteNode? { get }
    var statum: TickStatum? { get }
    var stepper: Stepper? { get set }

    init(stepper: Stepper)
    func enter()
//    func go()
    func isViable() -> Bool
    func leave(to state: TickState)
    func work() -> TickState
}

class TickStateBase: TickStateProtocol {
    var core: Arkon { return stepper!.core }
    var isEngaged = false
    var metabolism: Metabolism { return stepper!.metabolism }
    var sprite: SKSpriteNode? { return stepper?.sprite }
    var statum: TickStatum? { return stepper?.tickStatum }
    weak var stepper: Stepper?

    required init(stepper: Stepper) { self.stepper = stepper }

    func enter() {}
//    func go() {}
    func isViable() -> Bool { return true }
    func leave(to state: TickState) {}
    func work() -> TickState { fatalError() }
}

enum SyncState { case sync, async }

class TickStatum {
    static let asyncQueue = DispatchQueue(
        label: "arkonia.asynq", qos: .background,
        attributes: DispatchQueue.Attributes.concurrent
    )

    static let syncQueue = DispatchQueue(
        label: "arkonia.synq", qos: .background
    )

    var action: SKAction?
    weak var actioner: SKSpriteNode?
    var currentState = TickState.start
    var states: [TickState: TickStateProtocol]!
    weak var stepper: Stepper?
    var syncState = SyncState.async

    init(stepper: Stepper) {
        stepper.tickStatum = self
        stepper.isAlive = true
        self.stepper = stepper

        states = [
            TickState.apoptosize: TickState.Apoptosize(stepper: stepper),
            TickState.arrive:     TickState.Arrive(stepper: stepper),
            TickState.colorize:   TickState.Colorize(stepper: stepper),
            TickState.dead:       TickState.Dead(stepper: stepper),
            TickState.metabolize: TickState.Metabolize(stepper: stepper),
            TickState.shiftable:  TickState.Shift(stepper: stepper),
            TickState.spawnable:  TickState.Spawnable(stepper: stepper),
            TickState.start:      TickState.Start(stepper: stepper)
        ]
    }

    func actionize() -> Bool {
        if let action = self.action {
//            print("actionize1")
            guard let actioner = self.actioner else { fatalError() }
//            print("actionize2")

            actioner.run(action)
//            print("actionize3")
            self.action = nil
            self.actioner = nil
//            print("actionize4")
            return true
        }

        return false
    }

    private func statumEnter() {
//        print("statumEnter0")
        if action != nil { return }

//        print("statumEnter1")
        guard let cs = states[currentState] else { print("stepper gone in statumEnter"); return }

        if !cs.isViable() { print("state dead in statumEnter"); return }

        cs.enter()

        stepper?.isEngaged = true
        syncState = .async  // Announce end of sync before it happens

         TickStatum.asyncQueue.async { [weak self] in
//            print("statumEnter async1")
            self?.statumWork()
//            print("statumEnter async2")
        }

//        print("statumEnter2")
    }

    private func statumGo() {
//        print("statumGo0")
        if action != nil { return }

        guard let cs = states[currentState] else { print("stepper gone in statumGo"); return }

        if !cs.isViable() { print("state dead in statumGo"); return }

//        print("statumGo1")
        TickStatum.syncQueue.sync {
            syncState = .sync   // Announce end of .async only when we're in .sync
//            print("statumGo sync1")
            statumEnter()
//            print("statumGo sync2")
        }
//        print("statumGo2")
    }

    func statumLaunch() {
        if actionize() { return }
        statumGo()
    }

    func statumLeave(to state: TickState) {
//        print("statumLeave0(to \(state))")
        if actionize() { return }

        guard let cs = states[currentState] else { print("stepper gone in statumLeave"); return }

        if !cs.isViable() { print("state dead in statumLeave"); return }
//        print("statumLeave1(to \(state))")

        TickStatum.asyncQueue.async { [weak self] in
//            print("statumLeave(to \(state)) async1")
            guard let cs = self?.currentState else { print("stepper gone in statumLeave async"); return }
            self?.states[cs]?.leave(to: state)
            self?.currentState = state
            self?.statumGo()
//            print("statumLeave(to \(state)) async2")
        }
//        print("statumLeave2(to \(state))")
    }

    private func statumWork() {
//        print("statumWork0")
        if action != nil { return }

        guard let cs = states[currentState] else { print("stepper gone in statumWork"); return }

        if !cs.isViable() { print("state dead in statumWork"); return }

//        print("statumWork1")
        let nextState = states[currentState]!.work()
        statumLeave(to: nextState)
//        print("statumWork2")
    }
}

enum TickState: CaseIterable {
    case action, apoptosize, arrive, colorize, dead, metabolize, nop, shiftable, spawnable, start

    class Dead: TickStateBase {
        required init(stepper: Stepper) { super.init(stepper: stepper) }

        override func enter() { }
        override func isViable() -> Bool { return false }
        override func leave(to state: TickState) { }
        override func work() -> TickState { fatalError() }
    }
}
