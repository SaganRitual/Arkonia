import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    private var mannaMagazine: Cbuffer<Manna>

    private(set) var nextBlast = Date()
    private var nextBlastPlotSS = 0

    private var cReplantsAttempted = 0
    private var cReplantsToAttempt = 0
    private var cReplantFailures = 0

    var replantDispatch = DispatchQueue(
        label: "ak.manna.replant", target: DispatchQueue.global(qos: .userInitiated)
    )

    private(set) var fertileSpots: [FertileSpot]

    init() {
        mannaMagazine = Cbuffer<Manna>(cElements: Arkonia.cMannaMorsels)

        fertileSpots = (0..<Arkonia.cFertileSpots).map { _ in FertileSpot() }
    }

    func blast() {
        var currentMorsel: Manna?
        var resetCounters = true

        func a() { replantDispatch.async(execute: b) }

        func b() {
            if resetCounters {
                cReplantsAttempted = 0
                cReplantFailures = 0
                cReplantsToAttempt = mannaMagazine.count
                resetCounters = false
            }

            Debug.log(level: 130) { "blast.b \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
            c()
        }

        func c() {
            if cReplantsAttempted < cReplantsToAttempt {
                Debug.log(level: 130) { "blast.c1 \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
                if currentMorsel == nil { currentMorsel = mannaMagazine.pop() }
                cReplantsAttempted += 1
                currentMorsel!.replant(d)
                return
            }

            Debug.log(level: 130) { "blast.c2 \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
            scheduleBlast()
        }

        func d(_ didPlant: Bool) {
            if didPlant {
                Debug.log(level: 130) { "blast.didPlant \(six(currentMorsel?.sprite.sprite.name)) \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
                cReplantFailures = 0
                currentMorsel = nil
            } else {
                Debug.log(level: 130) { "blast.didNotPlant \(six(currentMorsel?.sprite.sprite.name)) \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
                cReplantFailures += 1
                if cReplantFailures < 5 {
                    Debug.log(level: 130) { "blast.retryPlantOnNewThread \(six(currentMorsel?.sprite.sprite.name)) \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
                    a()
                    return }
                Debug.log(level: 130) { "blast.giveUp \(six(currentMorsel?.sprite.sprite.name)) \(cReplantsAttempted) <? \(cReplantsToAttempt) <- \(mannaMagazine.count)" }
            }

            c()
        }

        a()
    }

    func postInit() {
        (0..<Arkonia.cMannaMorsels).forEach { fishNumber in
            let m = Manna(fishNumber)
            m.mark()
            mannaMagazine.push(m)

            Debug.log(level: 129) { "postInit \(fishNumber) \(six(m.sprite.sprite.name))" }
        }

        blast()
    }

    func refurbishManna(_ manna: Manna, _ onComplete: @escaping () -> Void) {
        replantDispatch.async { self.refurbishManna(manna); onComplete() }
    }

    func refurbishManna(_ manna: Manna) {
        Debug.log(level: 129) { "refurbishManna \(six(manna.sprite.sprite.name))" }

        self.mannaMagazine.push(manna)
    }

    func scheduleBlast() {
        let p = MannaCannon.nextBlastPlot[nextBlastPlotSS]

        nextBlastPlotSS = (nextBlastPlotSS + 1) % MannaCannon.nextBlastPlot.count

        self.nextBlast += p

        replantDispatch.asyncAfter(wallDeadline: .now() + p, execute: blast)
    }
}
