import GameplayKit

extension TickState {
    class ColorizePending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class Colorize: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.Colorize {

    override func update(deltaTime seconds: TimeInterval) {
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default

        let colorizeLeave = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("gco1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("gco2", self?.core?.selectoid.fishNumber ?? -1)

            myself.stateMachine?.enter(TickState.Shiftable.self)
            myself.stateMachine?.update(deltaTime: 0)
        }

        let colorizeWork = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("fco", self?.core?.selectoid.fishNumber ?? -1)
            self?.colorize()
            gq.async(execute: colorizeLeave)
        }

        let colorizeEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("eco", self.core?.selectoid.fishNumber ?? -1)
            self?.stateMachine?.enter(TickState.ColorizePending.self)
            self?.stateMachine?.update(deltaTime: 0)
            gq.async(execute: colorizeWork)
        }

        gq.async(execute: colorizeEnter)
    }

    func colorize() {
        guard let core = self.core else { return }
        guard let mb = self.metabolism else { return }
        guard let sprite = self.sprite else { return }

        let ef = mb.fungibleEnergyFullness
        core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if core.selectoid.fishNumber < 10 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = ((metabolism?.spawnEnergyFullness ?? 0) > 0) ?
                Arkon.brightColor : Arkon.standardColor
        }

        let four: CGFloat = 4
        sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism?.spawnEnergyFullness ?? 0,
            bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
        )

        sprite.colorBlendFactor = metabolism?.oxygenLevel ?? 0
    }
}
