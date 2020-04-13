import Foundation
import SpriteKit

class Dashboard {
    var node: SKNode
    var quadrants: [Quadrant]

    init(node: SKNode, quadrants: [Quadrant]) {
        self.node = node
        self.quadrants = quadrants
    }
}

class Quadrant {
    var monitor: SKSpriteNode?
    let quadrantPosition: CGPoint

    init(monitor: SKSpriteNode, quadrantPosition: CGPoint) {
        self.monitor = monitor
        self.quadrantPosition = quadrantPosition
    }
}

class HUD {
    enum MonitorPrototype: Int, CaseIterable {
        case report = 0, barchart = 1, placeholder1c = 2, linegraph = 3
    }

    enum PlaceholderPrototype: Int, CaseIterable {
        case placeholder2a = 0, placeholder2b = 1, placeholder2c = 2, placeholder2d = 3
    }

    static private let monitorPrototypeNames: [MonitorPrototype: String] = [
        .report: "report_monitor_prototype",
        .barchart: "barchart_monitor_prototype",
        .placeholder1c: "placeholder1c",
        .linegraph: "linegraph_monitor_prototype"
    ]

    static private let placeholderPrototypeNames: [PlaceholderPrototype: String] = [
        .placeholder2a: "placeholder2a",
        .placeholder2b: "placeholder2b",
        .placeholder2c: "placeholder2c",
        .placeholder2d: "placeholder2d"
    ]

    private(set) var dashboards = [Dashboard]()
    private let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene

        let monitorPrototypes = HUD.unpackPrototypes(ArkoniaScene.dashboardsPortal0, scene: scene)
        dashboards.append(Dashboard(node: ArkoniaScene.dashboardsPortal0, quadrants: monitorPrototypes))

        let placeholderPrototypes = HUD.unpackPlaceholders(ArkoniaScene.dashboardsPortal1, scene: scene)
        dashboards.append(Dashboard(node: ArkoniaScene.dashboardsPortal1, quadrants: placeholderPrototypes))
    }

    func getNetPortal() -> SKNode {
        return scene.childNode(withName: "net_portal")!
    }

    func getMonitorPrototype(_ whichOne: MonitorPrototype, from dashboard: Dashboard) -> SKNode? {
        return dashboard.quadrants[whichOne.rawValue].monitor
    }

    func getPlaceholderPrototype(_ whichOne: PlaceholderPrototype, from dashboard: Dashboard) -> SKNode? {
        return dashboard.quadrants[whichOne.rawValue].monitor
    }

    func placeMonitor(_ monitor: SKSpriteNode, dashboard whichDashboard: Int, quadrant whichQuadrant: Int) {
        let dashboard = dashboards[whichDashboard]
        let quadrant = dashboard.quadrants[whichQuadrant]

        quadrant.monitor?.removeFromParent()

        if let x = monitor.getKeyField(SpriteUserDataKey.x, require: false) as? CGFloat,
            let y = monitor.getKeyField(SpriteUserDataKey.y, require: false) as? CGFloat {
            monitor.position = CGPoint(x: x, y: y)
        } else {
            monitor.position = quadrant.quadrantPosition
        }

        dashboard.node.addChild(monitor)
    }

    func releasePrototype(_ thePrototype: SKNode) {
        thePrototype.removeFromParent()
    }

    static private func unpackPrototypes(_ dashboard: SKNode, scene: SKScene) -> [Quadrant] {
        let quadrants: [Quadrant] = MonitorPrototype.allCases.compactMap { monitorType in
            guard let name = monitorPrototypeNames[monitorType] else { fatalError() }

            guard let monitorPrototype: SKSpriteNode =
                dashboard.childNode(withName: name) as? SKSpriteNode else {
                    Debug.log { "monitorPrototype \(monitorType)(\(name)) not found in \(dashboard.name!)" }
                    return nil
            }

            return Quadrant(
                monitor: monitorPrototype, quadrantPosition: monitorPrototype.position
            )
        }

        return quadrants
    }

    static private func unpackPlaceholders(_ dashboard: SKNode, scene: SKScene) -> [Quadrant] {
        let quadrants: [Quadrant] = PlaceholderPrototype.allCases.compactMap { placeholderType in
            guard let name = placeholderPrototypeNames[placeholderType] else { fatalError() }

            guard let placeholderPrototype: SKSpriteNode =
                dashboard.childNode(withName: name) as? SKSpriteNode else { return nil }

            return Quadrant(
                monitor: placeholderPrototype, quadrantPosition: placeholderPrototype.position
            )
        }

        return quadrants
    }
}
