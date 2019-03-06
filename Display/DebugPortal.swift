import Foundation
import SpriteKit

enum SpecimenID {
    case cAttempted, cBirthFailed, cLivingArkons, cPendingGenomes, currentOldest, healthOfOldest
    case cLiveGenomes, cLiveGenes, oldestCOffspring
}

class Specimen: Hashable, Equatable {
    var label: SKLabelNode
    let specimenID: SpecimenID
    let sprite: SKSpriteNode
    let text: String
    var value = 0

    init(portal: SKSpriteNode, specimenID: SpecimenID, text: String) {
        self.specimenID = specimenID

        self.label = SKLabelNode(text: text)
        self.label.zPosition = ArkonCentralLight.vLabelZPosition
        self.label.fontColor = .green
        self.label.fontName = "Courier New"
        self.label.fontSize = 80

        self.sprite = SKSpriteNode(color: portal.color, size: portal.parent!.frame.size)
        self.sprite.color = .black
        self.sprite.colorBlendFactor = 1.0
        self.sprite.zPosition = ArkonCentralLight.vLabelCotainerZPosition

        self.sprite.setScale(0.33)

        self.text = text

        portal.addChild(self.sprite)
        self.sprite.addChild(self.label)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.specimenID)
    }

    func tick() {
        self.label.text = self.text + " = \(value)"
    }

    static func == (lhs: Specimen, rhs: Specimen) -> Bool {
        return lhs.specimenID == rhs.specimenID
    }
}

class DebugPortal {
    static var shared: DebugPortal!

    private weak var portal: SKSpriteNode!
    var specimens = [SpecimenID: Specimen]()

    init() {
        self.portal = Display.shared.getPortal(quadrant: 3)
        self.portal.color = Display.shared.scene!.backgroundColor
        self.portal.colorBlendFactor = 1.0

        addSpecimenViewer(portal: portal, specimenID: .cAttempted, text: "cAttempted")
        addSpecimenViewer(portal: portal, specimenID: .cBirthFailed, text: "cFailed")
        addSpecimenViewer(portal: portal, specimenID: .cLiveGenes, text: "cLiveGenes")
        addSpecimenViewer(portal: portal, specimenID: .cLiveGenomes, text: "cLiveGenomes")
        addSpecimenViewer(portal: portal, specimenID: .cLivingArkons, text: "cLiving")
        addSpecimenViewer(portal: portal, specimenID: .cPendingGenomes, text: "cPending")
        addSpecimenViewer(portal: portal, specimenID: .currentOldest, text: "senior age")
        addSpecimenViewer(portal: portal, specimenID: .healthOfOldest, text: "health")
        addSpecimenViewer(portal: portal, specimenID: .oldestCOffspring, text: "cOffspring")

    }

    func addSpecimenViewer(portal: SKSpriteNode, specimenID: SpecimenID, text: String) {
        let specimen = Specimen(portal: portal, specimenID: specimenID, text: text)
        self.specimens[specimenID] = specimen

        let increment = CGPoint(portal.parent!.frame.size / 6)
        switch specimenID {
        case .cAttempted:       specimen.sprite.position = increment * CGPoint(x: -2, y:  0)
        case .cBirthFailed:     specimen.sprite.position = increment * CGPoint(x: -2, y: -2)
        case .cLiveGenes:       specimen.sprite.position = increment * CGPoint(x:  0, y:  2)
        case .cLiveGenomes:     specimen.sprite.position = increment * CGPoint(x: -2, y:  2)
        case .cLivingArkons:    specimen.sprite.position = increment * CGPoint(x:  0, y:  0)
        case .cPendingGenomes:  specimen.sprite.position = increment * CGPoint(x:  0, y: -2)
        case .currentOldest:    specimen.sprite.position = increment * CGPoint(x:  2, y:  2)
        case .healthOfOldest:   specimen.sprite.position = increment * CGPoint(x:  2, y:  0)
        case .oldestCOffspring: specimen.sprite.position = increment * CGPoint(x:  2, y: -2)
        }
    }

    func tick() {
        for (_, specimen) in specimens { specimen.tick() }
    }
}
