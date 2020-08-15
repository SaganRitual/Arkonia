import SpriteKit
import SwiftUI

class Census {
    static var shared = Census()

    let censusAgent = CensusAgent()

    var populated = false

    // Markers for said arkons, not the arkons themselves
    var oldestLivingMarker, brainiestLivingMarker, busiestLivingMarker: SKSpriteNode?
    var markers = [SKSpriteNode]()

    var tickTimer: Timer!

    static let dispatchQueue = DispatchQueue(
        label: "ak.census.q",
        target: DispatchQueue.global()
    )

    func start() {
        setupMarkers()
        seedWorld()
        updateReports()
    }

    func reSeedWorld() { populated = false }

    func setupMarkers() {
        let atlas = SKTextureAtlas(named: "Backgrounds")
        let texture = atlas.textureNamed("marker")

        oldestLivingMarker = SKSpriteNode(texture: texture)
        busiestLivingMarker = SKSpriteNode(texture: texture)
        brainiestLivingMarker = SKSpriteNode(texture: texture)

        markers.append(contentsOf: [
            oldestLivingMarker!, busiestLivingMarker!, brainiestLivingMarker!
        ])

        let colors: [SKColor] = [.yellow, .green, .magenta]

        zip(0..., markers).forEach { ss, marker in
            marker.color = colors[ss]
            marker.colorBlendFactor = 1
            marker.zPosition = 10
            marker.setScale(Arkonia.markerScaleFactor / (CGFloat(ss) + 1.25 - CGFloat(ss) * 0.45))
        }
    }
}

extension Census {
    static func getAge(of arkon: Stepper, at currentTime: Int) -> TimeInterval {
        return TimeInterval(currentTime) - arkon.fishday.birthday
    }
}

private extension Census {
    func updateReports() {
        Clock.dispatchQueue.asyncAfter(deadline: .now() + 1) {
            let wc = Int(Clock.shared.worldClock)
            self.updateReports_B(wc)
        }
    }

    func updateReports_B(_ worldClock: Int) {
        Census.dispatchQueue.async {
            self.censusAgent.compress(TimeInterval(worldClock))
            self.markExemplars()    // No need to wait on this; it's a sprite update
            self.updateReports_C()
        }
    }

    func updateReports_C() {
        DispatchQueue.main.async {
            self.censusAgent.stats.hudUpdateTrigger.toggle()
            self.updateReports()
        }
    }
}

private extension Census {
    func markExemplars() {
        SceneDispatch.shared.schedule("updateMarker") { markExemplars_B() }

        func markExemplars_B() {
            zip([
                censusAgent.stats.oldestArkon,
                censusAgent.stats.brainiestArkon,
                censusAgent.stats.busiestArkon
            ], [
                oldestLivingMarker,
                brainiestLivingMarker,
                busiestLivingMarker
            ]).forEach {
                (a, m) in
                guard let arkon = a, let marker = m else { return }
                updateMarker(marker, arkon.thorax)
            }
        }
    }

    func updateMarker(_ marker: SKSpriteNode, _ markCandidate: SKSpriteNode) {
        if marker.parent != nil {
            marker.alpha = 0
            marker.removeFromParent()
        }

        markCandidate.addChild(marker)

        marker.alpha = 1
    }
}
