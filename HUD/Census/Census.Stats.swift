import Foundation

struct PopulationStats {
    let averageAge: Double
    let maxAge: Double
    weak var oldestArkon: Stepper?

    let averageFoodHitRate: Double
    let maxFoodHitRate: Double
    weak var bestAimArkon: Stepper?

    let averageCOffspring: Double
    let maxCOffspring: Int
    weak var busiestArkon: Stepper?
}

class CitizenMinder {
    weak var citizen: Stepper?
    var next: UnsafeMutablePointer<CitizenMinder>?
    var prev: UnsafeMutablePointer<CitizenMinder>?

    init(_ citizen: Stepper) { self.citizen = citizen }
}

class CensusData {
    var head: UnsafeMutablePointer<CitizenMinder>?
    var tail: UnsafeMutablePointer<CitizenMinder>?

    var isEmpty: Bool { head == nil }

    var stats: PopulationStats?

    func compress(_ currentTime: TimeInterval) {
        var cArkons = 0
        var ageSum = TimeInterval(0), maxAge = TimeInterval(-1)
        var maxFoodHitRate = -1.0
        var foodHitRateSum = -1.0
        var maxCOffspring = -1
        var cOffspringSum = 0

        var currentMinder = self.head

        // Citizens disappear from the roster when their steppers destruct. We
        // see this as a nil citizen in the minder. Minders stick around until
        // we see that their citizen has died, at which point we, uhh, "retire" the minder
        var oldestArkon, bestAimArkon, busiestArkon: Stepper?

        repeat {
            guard let minder = currentMinder else { break } // End of the list

            guard let info = minder.pointee.citizen else {
                currentMinder = delete(minder.pointee)
                continue
            }

            let age = currentTime - info.fishday.birthday
            ageSum += age

            if let (newMax, arkon) = checkMax(
                age, maxAge, minder.pointee.citizen!
            ) { maxAge = newMax; oldestArkon = arkon }

            let foodHitRate = info.cJumps == 0 ? 0 : Double(info.cFoodHits) / Double(info.cJumps)
            foodHitRateSum += foodHitRate

            if let (newMax, arkon) = checkMax(
                foodHitRate, maxFoodHitRate, minder.pointee.citizen!
            ) { maxFoodHitRate = newMax; bestAimArkon = arkon }

            if let (newMax, arkon) = checkMax(
                Double(info.cOffspring), Double(maxCOffspring), minder.pointee.citizen!
            ) { maxCOffspring = Int(newMax); busiestArkon = arkon }

            cOffspringSum += info.cOffspring

            cArkons += 1

            currentMinder = currentMinder!.pointee.next
        } while currentMinder != nil

        self.stats = PopulationStats(
            averageAge: Double(ageSum) / Double(cArkons),
            maxAge: Double(maxAge),
            oldestArkon: oldestArkon,
            averageFoodHitRate: foodHitRateSum / Double(cArkons),
            maxFoodHitRate: maxFoodHitRate,
            bestAimArkon: bestAimArkon,
            averageCOffspring: Double(cOffspringSum) / Double(cArkons),
            maxCOffspring: maxCOffspring,
            busiestArkon: busiestArkon
        )
    }

    private func checkMax(
        _ testValue: Double, _ maxValue: Double, _ arkon: Stepper
    ) -> (Double, Stepper)? {
        testValue > maxValue ? (testValue, arkon) : nil
    }

    // Clients don't need to delete nodes. We keep weak refs, so when the
    // arkon goes away, we drop it off the list automatically
    private func delete(_ node: CitizenMinder) -> UnsafeMutablePointer<CitizenMinder>? {
        guard let head = self.head, let tail = self.tail else { fatalError() }

        // Note: identity, not just equality, although I imagine equality would be fine
        if head.pointee === node && tail.pointee === node {
            // Deleting the only remaining node on the list
            self.head = nil
            self.tail = nil
            return nil

        } else if head.pointee === node { // Deleting first node

            self.head = node.next
            node.next!.pointee.prev = self.head // we know there's a next bc the tail is non-nil
            return node.next

        } else if tail.pointee === node { // Deleting last node

            self.tail = node.prev
            node.prev!.pointee.next = self.tail
            return nil

        } else { // Deleting somewheres in the middle

            node.prev!.pointee.next = node.next
            node.next!.pointee.prev = node.prev
            return node.next
        }
    }

    // Always insert at the front; we don't care about order or nuthin
    func insert(_ stepper: Stepper) {
        if head == nil {
            head = UnsafeMutablePointer<CitizenMinder>.allocate(capacity: 1)
            head!.initialize(to: CitizenMinder(stepper))

            tail = head
        } else {
            head!.pointee.prev = UnsafeMutablePointer<CitizenMinder>.allocate(capacity: 1)
            head!.pointee.prev!.initialize(to: CitizenMinder(stepper))

            head!.pointee.prev!.pointee.next = head
            head = head!.pointee.prev
        }
    }
}
