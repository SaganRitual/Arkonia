import Foundation
import SpriteKit

enum SpecimenID {
    case avgLiveAge, avgLiveGenes, blArkons, cLiveArkons, cLiveGenes, cOffspring
    case cSpawn, cSpawnFailure, cSpawnSuccess, foodValue, gameAge, generation, health
    case hwAge, hwLiveArkons, hwLiveGenes, hwOffspring, seniorAge
    case liveLabel, seniorLabel
}

class SpecimenDescriptor {
    var label: SKLabelNode
    var specimenID: SpecimenID
    var text: String
    var value: Double

    init(_ label: SKLabelNode, _ specimenID: SpecimenID, _ text: String, _ value: Double) {
        self.label = label; self.specimenID = specimenID; self.text = text; self.value = value
    }
}

class Specimen {
    let specimenDescriptors: [SpecimenDescriptor]
    let sprite: SKSpriteNode

    init(portal: SKSpriteNode, specimenDescriptors: [SpecimenDescriptor]) {
        self.specimenDescriptors = specimenDescriptors

        specimenDescriptors.forEach {
            $0.label = SKLabelNode(text: $0.text)
            $0.label.zPosition = ArkonCentralLight.vLabelZPosition
            $0.label.fontColor = .green
            $0.label.fontName = "Courier New"
            $0.label.fontSize = 80
        }

        self.sprite = SKSpriteNode(color: portal.color, size: portal.parent!.frame.size)
        self.sprite.color = .black
        self.sprite.colorBlendFactor = 1.0
        self.sprite.zPosition = ArkonCentralLight.vLabelCotainerZPosition

        self.sprite.setScale(0.33)

        portal.addChild(self.sprite)

        specimenDescriptors.forEach { self.sprite.addChild($0.label) }
    }

    func hash(into hasher: inout Hasher) {
        self.specimenDescriptors.forEach { hasher.combine($0.specimenID) }
    }

    func tick() {
        self.specimenDescriptors.forEach { $0.label.text = $0.text + " = \($0.value)" }
    }
}

class DebugPortal {
    static var shared: DebugPortal!

    private weak var portal: SKSpriteNode!
    var specimens = [SpecimenDescriptor]()

    init() {
        self.portal = Display.shared.getPortal(quadrant: 3)
        self.portal.color = Display.shared.scene!.backgroundColor
        self.portal.colorBlendFactor = 1.0

        let viewerContents: [(SpecimenID, String)] = [
            (.avgLiveAge, "average"), (.avgLiveGenes, "average"), (.blArkons, "backlog"),
            (.cLiveArkons, "arkons"), (.cLiveGenes, "genes"), (.cOffspring, "offspring"),
            (.cSpawn, "spawns"), (.cSpawnFailure, "failures"), (.cSpawnSuccess, "successes"),
            (.foodValue, "food value"), (.gameAge, ""), (.health, "health"),
            (.hwAge, "record"), (.hwLiveArkons, "record"), (.hwLiveGenes, "genes"),
            (.hwOffspring, "record"), (.seniorAge, "age"), (.generation, "generation")
        ]

        viewerContents.forEach {
            let (id, text) = ($0.0, $0.1)
            addSpecimenViewer(portal: portal, specimenID: id, text: text)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func addSpecimenViewer(portal: SKSpriteNode, specimenID: SpecimenID, text: String) {
        guard [
            SpecimenID.gameAge, SpecimenID.liveLabel, SpecimenID.seniorLabel,
            SpecimenID.foodValue, SpecimenID.cLiveGenes, SpecimenID.seniorAge,
            SpecimenID.generation, SpecimenID.health, SpecimenID.cLiveArkons
        ].contains(specimenID) else { return }

        let specimen = Specimen(portal, specimenID, text)
        self.specimens[specimenID] = specimen

        let increment = CGPoint(portal.parent!.frame.size / 6)
        switch specimenID {
        case .gameAge     :  specimen.sprite.position = increment * CGPoint(x: -2, y:  2)
        case .liveLabel   :  specimen.sprite.position = increment * CGPoint(x:  0, y:  2)
        case .seniorLabel :  specimen.sprite.position = increment * CGPoint(x:  2, y:  2)

        case .foodValue:   specimen.sprite.position = increment * CGPoint(x: -2, y:  0)
        case .cLiveGenes:  specimen.sprite.position = increment * CGPoint(x:  0, y:  0)
        case .seniorAge:   specimen.sprite.position = increment * CGPoint(x:  2, y:  0)

        case .generation:  specimen.sprite.position = increment * CGPoint(x: -2, y: -2)
        case .health:      specimen.sprite.position = increment * CGPoint(x:  0, y: -2)
        case .cLiveArkons: specimen.sprite.position = increment * CGPoint(x:  2, y: -2)
        default: break
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func tick() {
        for (_, specimen) in specimens { specimen.tick() }
    }
}
