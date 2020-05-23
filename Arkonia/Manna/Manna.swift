import SpriteKit

class Manna {
    fileprivate var timeRequiredForFullBloom = Arkonia.mannaFullGrowthDurationSeconds
    fileprivate let fishNumber: Int
    fileprivate var mostRecentBloomTime: Date
    let sprite: Manna.Sprite

    var isPhotosynthesizing: Bool { self.sprite.isPhotosynthesizing }

    init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.sprite = Manna.Sprite(fishNumber)
        self.sprite.reset()

        // Set our date to the past so we'll treat the first bloom as completed already
        self.mostRecentBloomTime = Date() - Arkonia.mannaFullGrowthDurationSeconds
    }
}

extension Manna {
    class Sprite {
        weak var gridCell: GridCell?
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = ArkonName.makeMannaName(fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }
    }
}

extension EnergyBudget {
    struct MannaContent: HasSelectableStore {
        // swiftlint:disable nesting
        // "Nesting Violation: Types should be nested at most 1 level deep (nesting)"
        typealias StoreType = CGFloat
        // swiftlint:enable nesting

        let bone:    CGFloat = 1
        let ham:     CGFloat = 1000   // Manna contains ham; arkons convert it directly to energy
        let leather: CGFloat = 1
        let o2:      CGFloat = 700

        let maturityLevel: CGFloat
        let scale: CGFloat
        let seasonalFactors: CGFloat

        init(_ maturityLevel: CGFloat = 1, _ seasonalFactors: CGFloat) {
            self.maturityLevel = maturityLevel
            self.seasonalFactors = seasonalFactors
            self.scale = EnergyBudget.supersizer * maturityLevel * seasonalFactors
        }

        func selectStore(_ organID: OrganID) -> CGFloat? {
            switch organID {
            case .bone:     return bone * scale
            case .energy:   return ham * scale
            case .fatStore: return nil
            case .leather:  return leather * scale
            case .lungs:    return o2 * scale
            default: fatalError()
            }
        }
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (EnergyBudget.MannaContent?) -> Void) {
        let maturityLevel = sprite.getMaturityLevel()

        // Don't give up any nutrition at all until I've bloomed enough
        if maturityLevel < 1e-2 { onComplete(nil); return }

        MannaCannon.mannaPlaneQueue.async {
            MannaCannon.shared!.cPhotosynthesizingManna -= 1
        }

        sprite.gridCell!.mannaAwaitingRebloom = true

        Seasons.shared.getSeasonalFactors { dayNightFactor, temperatureCelsiusDegreees in
            let seasonalFactors =  dayNightFactor * temperatureCelsiusDegreees
            let mannaContent = EnergyBudget.MannaContent(maturityLevel, seasonalFactors)

            Debug.log(level: 182) {
                "harvest:"
                + " maturity \(maturityLevel)"
                + " dayNight \(dayNightFactor)"
                + " weather \(temperatureCelsiusDegreees)"
                + " = \(maturityLevel * seasonalFactors)"
                + " -> ham \(mannaContent.selectStore(.energy)!)"
            }

            Dispatch.dispatchQueue.async { onComplete(mannaContent) }
        }
    }

    func plant() -> Bool {
        let cell = GridCell.getRandomCell()
        guard cell.manna == nil else { return false }

        Debug.log(level: 156) { "plant \(self.fishNumber) at \(cell.gridPosition)" }
        cell.manna = self
        self.sprite.firstBloom(at: cell)
        return true
    }

    enum RebloomResult { case died, rebloomed }

    func rebloom() {
        hardAssert(Display.displayCycle == .updateStarted)

        sprite.reset()

        // Check for pollenators above me; if none, go back to sleep for a while
        let mc = MannaCannon.shared!

        guard let pollenator = mc.pollenators.first (
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { mc.blast(self); return }

        // If I'm being harvested before I've reached full maturity, it will
        // take proportionally longer for me to reach it this time. The delay is
        // cumulative: say the normal bloom time is 10s, and I mature only up to
        // 6.3s, when an arkon grazes me. It will take me a total of
        // (normal bloom time + (10 - 6.3s)) * 10s/5s =
        // (normal bloom time + 3.7) * 2 seconds to reach full maturity
        let now = Date()
//        let growthDuration = mostRecentBloomTime.distance(to: now)
//        let maturity = constrain(growthDuration / timeRequiredForFullBloom, lo: 0.5, hi: 1.0)
//        let catchup = timeRequiredForFullBloom * (1 - maturity)
        let catchup: TimeInterval = 0

        timeRequiredForFullBloom = catchup + Arkonia.mannaFullGrowthDurationSeconds
        mostRecentBloomTime = now

//        #if DEBUG
//        Debug.log(level: 171) { "rebloom \(growthDuration), \(maturity), \(catchup), \(timeRequiredForFullBloom)" }
//        #endif

        let node = pollenator.node
        sprite.bloom(timeRequiredForFullBloom, color: node.fillColor, scaleFactor: node.xScale)
    }
}

extension Debug {
    static func showMannaStats() {
        var cCells = 0, cPhotosynthesizing = 0

        for x in -Grid.shared.gridWidthInCells..<Grid.shared.gridWidthInCells {
            for y in -Grid.shared.gridHeightInCells..<Grid.shared.gridHeightInCells {
                let p = AKPoint(x: x, y: y)
                let c = Grid.shared.getCell(at: p)

                cCells += 1

                guard let manna = c.manna else {
                    continue
                }

                cPhotosynthesizing += manna.isPhotosynthesizing ? 1 : 0
            }
        }

        print("Manna stats; \(cCells) cells, \(cPhotosynthesizing) photosynthesizing")
    }
}
