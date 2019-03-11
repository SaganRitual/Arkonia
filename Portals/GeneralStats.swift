import SpriteKit

class GeneralStats {
    typealias Updater = () -> String

    var textFields = [[SKLabelNode]]()

    init(_ statsPortal: SKSpriteNode) {
        let generalPurposePortalNames: [(String, String)] = (0..<6).map {
            let labelSetName = String(format: "stats%02d", $0)
            let subportalName = String(format: labelSetName + "Subportal", $0)
            return (subportalName, labelSetName)
        }

        var llss = 0
        for (ss, portalNames) in zip(0..., generalPurposePortalNames) {
            let subportalName = portalNames.0
            let labelSetName = portalNames.1

            textFields.append([SKLabelNode]())

            guard let subportalSprite =
                statsPortal.childNode(withName: subportalName) as? SKSpriteNode
                else { preconditionFailure() }

            //            let llamaPhrases = [
            //                "Llamas: %d", "Anti-llamas: %d", "Uncle llamas: %d", "Alibaba llamas: %d",
            //                "Squeako llamas: %d", "MAGA llamas: %d", "MARA llamas: %d", "Yo llama: %d",
            //                "<Socialism!>", "Idle hands: %d", "Card hands: %d", "High hands: %d",
            //                "Desert hands: %d", "Dessert Hands %d", "LL Beans: %d", "Jellies: %d",
            //                "Bellies: %d"
            //            ]

            let saveCuzImTiredOfTheMath = subportalSprite.frame.size
            subportalSprite.xScale = 0.75
            subportalSprite.size = saveCuzImTiredOfTheMath
            subportalSprite.enumerateChildNodes(withName: labelSetName) { node, _ in
                guard let n = node as? SKLabelNode else { preconditionFailure() }
                n.color = .brown
                n.text = ""
                n.position.x = -subportalSprite.size.width / 1.75
                self.textFields[ss].append(n)

                llss += 1
            }
        }
    }

    func setUpdater(subportal: Int, field: Int, _ getText: @escaping Updater) {
        let delayAction = SKAction.wait(forDuration: 1.0)
        let node = self.textFields[subportal][field]

        let updateAction = SKAction.run { node.text = getText() }
        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])

        let randomDelayToImpressTheEasilyImpressed =
            SKAction.wait(forDuration: Double.random(in: 0..<1.0))

        let updateForever = SKAction.repeatForever(updateOncePerSecond)

        let allTogether = SKAction.sequence([
            randomDelayToImpressTheEasilyImpressed, updateForever
        ])

        node.run(allTogether)
    }
}
