import Foundation
import SpriteKit

enum SpecimenID {
    case cArkonBodies, cBirthFailed, cLivingArkons, cPendingGenomes
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

        self.sprite.setScale(0.5)

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

    init(_ display: Display) {
        self.portal = display.getPortal(quadrant: 2)
        self.portal.color = .black
        self.portal.colorBlendFactor = 1.0

        addSpecimenViewer(portal: portal, specimenID: .cArkonBodies, text: "cBodies")
        addSpecimenViewer(portal: portal, specimenID: .cBirthFailed, text: "cFailed")
        addSpecimenViewer(portal: portal, specimenID: .cLivingArkons, text: "cLiving")
        addSpecimenViewer(portal: portal, specimenID: .cPendingGenomes, text: "cPending")
    }

    func addSpecimenViewer(portal: SKSpriteNode, specimenID: SpecimenID, text: String) {
        let specimen = Specimen(portal: portal, specimenID: specimenID, text: text)
        self.specimens[specimenID] = specimen

        let increment = CGPoint(portal.parent!.frame.size / 4)
        switch specimenID {
        case .cArkonBodies:     specimen.sprite.position = increment * CGPoint(x:  1, y:  1)
        case .cBirthFailed:     specimen.sprite.position = increment * CGPoint(x: -1, y:  1)
        case .cLivingArkons:    specimen.sprite.position = increment * CGPoint(x: -1, y: -1)
        case .cPendingGenomes:  specimen.sprite.position = increment * CGPoint(x:  1, y: -1)
        }
    }

    func tick() {
        for (_, specimen) in specimens { specimen.tick() }
    }
}
