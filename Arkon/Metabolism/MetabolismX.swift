import Foundation

class MetabolismX {
     let bone:     Accessory
     let leather:  Accessory
     let oxygen:   Oxygen
     let poison:   Accessory
     let ready:    ReadyEnergy
     let spawn:    Organ
     let stomach:  Stomach

    private let allOrgans: [Organ]

    var mass: CGFloat { allOrgans.reduce(0) { $0 + $1.mass } }

    func absorbEnergy(_ cJoules: CGFloat) { stomach.deposit(cJoules); report() }
    func absorbVitamin(_ cVitaminoids: CGFloat, type: AccessoryType) {
        stomach.depositVitamin(cVitaminoids, type: type)
        report()
    }

    // Count oxygen in joules rather than grams, because everything else
    // is in joules, seems easier
    func inhale(_ cJoules: CGFloat) { oxygen.inhale(cJoules); report() }

    func report() {
        Debug.log(level: 174) {
            var exhausted = String()

            let line = [bone, leather, oxygen, poison, ready, spawn, stomach].reduce(into: String()) {
                let s1 = String(format: "%3.3f", $1.level).padding(toLength: 5, withPad: " ", startingAt: 0)
                let s2 = String(format: "%3.3f", $1.mass).padding(toLength: 5, withPad: " ", startingAt: 0)

                $0 += "\(s1) - \(s2)   "

                if $1.level <= 1e-5 {
                    switch $1 {
                    case is Oxygen:       exhausted += "\nOUT OF OXYGEN\n"
                    case is ReadyEnergy:  exhausted += "\nREADY RESERVES EMPTY\n"
                    default: break
                    }
                }
            }

            return line + exhausted
        }
    }

    internal init() {
        self.bone = Accessory(
            capacity: 10, energyDensity: 1, transferRate: 10, type: .bone
        )

        self.leather = Accessory(
            capacity: 10, energyDensity: 1, transferRate: 10, type: .leather
        )

        self.oxygen = Oxygen(
            capacity: 1, energyDensity: 0.2, transferRate: 10
        )

        self.poison = Accessory(
            capacity: 10, energyDensity: 1, transferRate: 10, type: .poison
        )

        self.ready = ReadyEnergy(
            capacity: 5, energyDensity: 1, transferRate: 5,
            overflowFullness: 0.75
        )

        self.spawn = Organ(
            capacity: 10, energyDensity: 25, transferRate: 10
        )

        self.stomach = Stomach(
            capacity: 10, energyDensity: 1, transferRate: 10
        )

        self.allOrgans = [
            bone, leather, oxygen, poison, ready, spawn, stomach
        ]

        self.ready.deposit(self.ready.capacity)
        self.oxygen.deposit(self.oxygen.capacity)
    }
}

// MARK: Energy withdrawal functions
// Notice that we need o2 to react with our energy when we withdraw from any
// of the energy reserves

extension MetabolismX {
    @discardableResult
    func withdrawEnergy(_ cJoules: CGFloat) -> CGFloat {
        return withdrawEnergy(cJoules, from: ready, to: nil)
    }

    private func withdrawEnergy(
        _ cJoules: CGFloat, from organ: Organ, to receiver: Organ?
    ) -> CGFloat {
        let netJoules = organ.withdraw(cJoules, receiver?.transferRate, oxygen.level)
        if netJoules > 0 { oxygen.combust(netJoules / 10) }
        report()
        return netJoules
    }

    private func withdrawFromReadySurplus(
        _ cJoules: CGFloat, to receiver: Organ?
    ) -> CGFloat {
        report()
        let netJoules = ready.withdraw(cJoules, receiver?.transferRate, oxygen.level)
        if netJoules > 0 { oxygen.combust(netJoules / 10) }
        report()
        return netJoules
    }

    @discardableResult
    private func withdrawMaxEnergy(
        from organ: Organ, to receiver: Organ?
    ) -> CGFloat {
        let netJoules = organ.withdrawMax(receiverRate: receiver?.transferRate, o2: oxygen.level)
        if netJoules > 0 { oxygen.combust(netJoules / 10) }
        report()
        return netJoules
    }

    func withdrawVitamin(_ cVitaminoids: CGFloat, from organ: AccessoryType) -> CGFloat {
        let netVitaminoids = ([bone, leather, poison][organ.rawValue]).withdrawVitamin(cVitaminoids, o2: oxygen.level)
        if netVitaminoids > 0 { oxygen.combust(netVitaminoids / 10) }
        report()
        return netVitaminoids
    }
}

// MARK: Digestion

extension MetabolismX {
    func digest() {
        let stomachToReady = !stomach.isEmpty && !ready.isFull

        if stomachToReady {
            let netJoules = withdrawMaxEnergy(from: stomach, to: ready)
            if netJoules > 0 { ready.deposit(netJoules) }
        }

        for accessory in [bone, leather, poison] {
            accessory.depositVitamin(from: stomach)
        }

        for receiver in [spawn, bone, leather, poison] {
            if !ready.isOverflowing { break }
            if receiver.isFull { continue }

            let requestJoules = receiver.capacity - receiver.level
            let cJoules = withdrawFromReadySurplus(requestJoules, to: receiver)
            if cJoules > 0 { receiver.deposit(cJoules) }
        }

        report()
    }
}
