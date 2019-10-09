import Dispatch

class Coordinator {
    let asyncQueue = DispatchQueue(
        label: "arkonia.asynq", qos: .background,
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global()
    )

    let syncQueue = DispatchQueue(
        label: "arkonia.synq", qos: .background
    )

    var core: Arkon { return stepper!.core }
    var metabolism: Metabolism { return stepper!.metabolism }
    var shift: Shift?
    weak var stepper: Stepper?

    init(stepper: Stepper) { self.stepper = stepper }
}

extension Coordinator {
    func actionComplete_cspawn() {
        let metabolorize = DispatchWorkItem { [unowned self] in
            self.metabolism.metabolize()
            self.core.colorize(bandaid: self, age: self.core.age)
        }

        asyncQueue.async(execute: metabolorize)
    }

    func actionComplete_metabolorize() {
        guard let st = stepper else { fatalError() }
        shift = Shift(stepper: st)

        let shiftStart = DispatchWorkItem { [unowned self] in
            self.shift!.start(gridlet: st.gridlet)
        }

        shiftStart.notify(queue: asyncQueue) { [unowned self] in
            self.dispatch(.shift)
        }

        syncQueue.sync(execute: shiftStart)
    }

    func actionComplete_shift() {
        let arrive = DispatchWorkItem { [unowned self] in
            self.stepper?.arrive()
        }

        arrive.notify(queue: asyncQueue) { [unowned self] in
            self.dispatch(.funge)
        }

        asyncQueue.async(execute: arrive)
    }

    func apoptosize() {
        let apoptosize = DispatchWorkItem { [unowned self] in
            self.stepper?.apoptosize()
        }

        asyncQueue.async(execute: apoptosize)
    }

    func cspawn() {
        guard let st = stepper else { fatalError() }

        let cspawn = DispatchWorkItem { st.cspawn() }
        asyncQueue.async(execute: cspawn)
    }

    func funge() {
        var isAlive = false
        let funge = DispatchWorkItem { [unowned self] in
            isAlive = self.metabolism.funge(self.core.age)
        }

        funge.notify(queue: asyncQueue) { [unowned self] in
            self.dispatch(isAlive ? .cspawn : .apoptosize)
        }

        asyncQueue.async(execute: funge)
    }
}

extension Coordinator {

    //swiftlint:disable cyclomatic_complexity
    func dispatch(_ workletID: WorkletID) {
        switch workletID {
        case .actionComplete_apoptosize:
            dispatch(.dead)

        case .actionComplete_cspawn: actionComplete_cspawn()

        case .actionComplete_metabolorize: actionComplete_metabolorize()

        case .actionComplete_shift: actionComplete_shift()

        case .actionComplete_spawn: dispatch(.funge)

        case .apoptosize: apoptosize()

        case .beParasitized: dispatch(.apoptosize)

        case .cspawn: cspawn()

        case .dead: print("dead")

        case .funge: funge()

        case .parasitize:
            stepper?.parasitismVictim?.coordinator.dispatch(.beParasitized)

        case .shift: shift!.shift(whereIAmNow: stepper!.gridlet)
        }
        //swiftlint:enable cyclomatic_complexity

    }
}

extension Coordinator {
    enum WorkletID {
        case actionComplete_apoptosize
        case actionComplete_cspawn
        case actionComplete_metabolorize
        case actionComplete_shift
        case actionComplete_spawn
        case apoptosize
        case beParasitized
        case cspawn
        case dead
        case funge
        case parasitize
        case shift
    }
}
