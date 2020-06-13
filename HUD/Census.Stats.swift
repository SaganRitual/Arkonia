import Foundation

struct CitizenInfo {
    var birthday: TimeInterval = 0
    var cFoodHits: Int = 0
    var cJumps: Int = 0
    var cOffspring: Int = 0
}

struct PopulationStats {
    let averageAge: Double
    let maxAge: Double

    let averageFoodHitRate: Double
    let maxFoodHitRate: Double

    let averageCOffspring: Double
    let maxCOffspring: Int
}

class CitizenMinder {
    weak var citizen: Stepper?
    var citizenInfo = CitizenInfo()
    var next: UnsafeMutablePointer<CitizenMinder>?
    var prev: UnsafeMutablePointer<CitizenMinder>?

    init(_ citizen: Stepper) {
        self.citizen = citizen
        citizenInfo.birthday = citizen.birthday
        citizenInfo.cFoodHits = citizen.cFoodHits
        citizenInfo.cJumps = citizen.cJumps
        citizenInfo.cOffspring = citizen.cOffspring
    }
}

class CensusData {
    var head: UnsafeMutablePointer<CitizenMinder>?
    var tail: UnsafeMutablePointer<CitizenMinder>?

    var isEmpty: Bool { head == nil }

    func compress(_ currentTime: TimeInterval) -> PopulationStats {
        var cArkons = 0
        var ageSum = TimeInterval(0), maxAge = TimeInterval(0)
        var maxFoodHitRate = 0.0
        var foodHitRateSum = 0.0
        var maxCOffspring = 0
        var cOffspringSum = 0

        var currentMinder = self.head

        // Citizens disappear from the roster when their steppers destruct. We
        // see this as a nil citizen in the minder. Minders stick around until
        // we see that their citizen has died, at which point we, uhh, "retire" the minder
        repeat {
            guard let minder = currentMinder else { break } // End of the list

            if minder.pointee.citizen == nil {
                currentMinder = delete(minder.pointee)
                continue
            }

            let info = minder.pointee.citizenInfo

            let age = currentTime - info.birthday
            maxAge = max(age, maxAge); ageSum += age

            let foodHitRate = Double(info.cFoodHits) / Double(info.cJumps)

            maxFoodHitRate = max(foodHitRate, maxFoodHitRate)
            foodHitRateSum += foodHitRate

            maxCOffspring = max(info.cOffspring, maxCOffspring)
            cOffspringSum += info.cOffspring

            cArkons += 1

            currentMinder = currentMinder!.pointee.next
        } while currentMinder != nil

        return PopulationStats(
            averageAge: Double(ageSum) / Double(cArkons),
            maxAge: Double(maxAge),
            averageFoodHitRate: foodHitRateSum / Double(cArkons),
            maxFoodHitRate: maxFoodHitRate,
            averageCOffspring: Double(cOffspringSum) / Double(cArkons),
            maxCOffspring: maxCOffspring
        )
    }

    private func delete(_ node: CitizenMinder) -> UnsafeMutablePointer<CitizenMinder>? {
        guard let head = self.head, let tail = self.tail else { fatalError() }

        // Note: identity, not just equality
        if head.pointee === node && tail.pointee === node { // Deleting the only remaining node on the list

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
