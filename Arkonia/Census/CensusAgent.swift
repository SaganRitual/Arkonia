import Foundation

class CitizenMinder {
    weak var citizen: Stepper?
    var next: UnsafeMutablePointer<CitizenMinder>?
    var prev: UnsafeMutablePointer<CitizenMinder>?

    init(_ citizen: Stepper) { self.citizen = citizen }
}

class CensusAgent {
    var head: UnsafeMutablePointer<CitizenMinder>?
    var tail: UnsafeMutablePointer<CitizenMinder>?

    var isEmpty: Bool { head == nil }

    var ages = [Stepper]()
    var brainiests = [Stepper]()
    var cOffsprings = [Stepper]()
    var stats = PopulationStats()

    // swifmlint:disable function_body_length
    // unction Body Length Violation: Function body should span 40 lines or
    // less excluding comments and whitespace:
    func compress(_ currentTime: TimeInterval) {
        stats.resetCore()

        var currentMinder = self.head

        // Citizens disappear from the roster when their steppers destruct. We
        // see this as a nil citizen in the minder. Minders stick around until
        // we see that their citizen has died, at which point we, uhh, "retire" the minder

        ages.removeAll(keepingCapacity: true)
        brainiests.removeAll(keepingCapacity: true)
        cOffsprings.removeAll(keepingCapacity: true)

        repeat {
            guard let minder = currentMinder else { break } // End of the list

            guard let arkon = minder.pointee.citizen else {
                currentMinder = delete(minder.pointee)
                continue
            }

            Debug.log(level: 226) { "addSample(cJumps: \(arkon.cJumps), cVeggieBites: \(arkon.cVeggieBites))" }
            stats.foodSuccessLineChartControls.addSample(cJumps: arkon.cJumps, cVeggieBites: arkon.cVeggieBites)

            stats.coreCNeurons += arkon.net.netStructure.cNeurons
            stats.coreCurrentPopulation += 1

            ages.append(arkon)
            brainiests.append(arkon)
            cOffsprings.append(arkon)

            stats.maxIf(.brainiest, value: Double(arkon.net.netStructure.cNeurons), arkon: arkon)

            if stats.coreCRoomy > 0 && arkon.net.netStructure.cNeurons < stats.coreCRoomy {
                stats.coreCRoomy = arkon.net.netStructure.cNeurons
            }

            let age = currentTime - arkon.fishday.birthday
            stats.maxIf(.oldest, value: age, arkon: arkon)

            stats.maxIf(.busiest, value: Double(arkon.censusData.cOffspring), arkon: arkon)

            currentMinder = currentMinder!.pointee.next
        } while currentMinder != nil

        (stats.coreAverageAge, stats.coreMedAge) = getAvgMedAge(currentTime: currentTime)
        (stats.coreAverageCOffspring, stats.coreMedCOffspring) = getAvgMedCOffspring()
        stats.coreCAverageNeurons = getAvgCNeurons()
    }
    // swiftmint:enable function_body_length

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
            node.next!.pointee.prev = nil // we know there's a next bc the tail is non-nil
            return node.next

        } else if tail.pointee === node { // Deleting last node

            self.tail = node.prev
            node.prev!.pointee.next = nil
            return nil

        } else { // Deleting somewheres in the middle

            node.prev!.pointee.next = node.next
            node.next!.pointee.prev = node.prev
            return node.next
        }
    }

    private func getAvgCNeurons() -> Double {
        self.brainiests.reduce(0, { $0 + Double($1.net.netStructure.cNeurons) }) / Double(self.brainiests.count)
    }

    private func getAvgMedAge(currentTime: TimeInterval) -> (TimeInterval, TimeInterval) {
        if self.ages.isEmpty { return (0, 0) }

        let m = self.ages.sorted { $0.name < $1.name }
        let ss = m.count / 2

        let median: TimeInterval
        if (m.count % 2) == 0  || m.count == 1 {
            median = currentTime - m[ss].fishday.birthday
        } else {
            median = (2 * currentTime - (m[ss].fishday.birthday + m[ss + 1].fishday.birthday)) / 2
        }

        let average = self.ages.reduce(0, { $0 + currentTime - $1.fishday.birthday }) / TimeInterval(self.ages.count)
        return (average, median)
    }

    private func getAvgMedCOffspring() -> (Double, Double) {
        if self.cOffsprings.isEmpty { return (0, 0) }

        let m = self.cOffsprings.sorted {
            $0.cOffspring < $1.cOffspring ||
            ($0.cOffspring == $1.cOffspring && $0.fishday.name < $1.fishday.name)
        }

        let ss = m.count / 2
        let median: Double

        if (m.count % 2) == 0  || m.count == 1 {
            median = Double(m[ss].cOffspring)
        } else {
            median = Double((m[ss].cOffspring + m[ss + 1].cOffspring) / 2)
        }

        let average = self.cOffsprings.reduce(0, { $0 + Double($1.cOffspring) }) / Double(self.cOffsprings.count)
        return (average, median)
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
