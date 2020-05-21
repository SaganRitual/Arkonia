import Foundation
import SpriteKit

enum HudPrototype: String {
    case barchart_monitor_prototype, dashboard_backer, empty_monitor_prototype
    case linegraph_monitor_prototype, report_monitor_prototype
}

enum HudLayout: String, CaseIterable {
    case dashboards_portal_1x1, dashboards_portal_1x2
    case dashboards_portal_2x1, dashboards_portal_2x2
}

class EmptyMonitorFactory {
    let hud: HUD

    init(hud: HUD) { self.hud = hud }

    func newPlaceholder() -> SKSpriteNode { return (hud.prototypes.empty.copy() as? SKSpriteNode)! }
}

class HUD {
    struct Prototypes {
        init(
            _ barchart: BarChart, _ dashboard: SKSpriteNode, _ empty: SKSpriteNode,
            _ lineGraph: LineGraph, _ report: Report
        ) {
            self.barchart = barchart
            self.dashboard = dashboard
            self.empty = empty
            self.lineGraph = lineGraph
            self.report = report

            [barchart, dashboard, empty, lineGraph, report].forEach { $0.removeFromParent() }
        }

        let barchart: BarChart
        let dashboard: SKSpriteNode
        let empty: SKSpriteNode
        let lineGraph: LineGraph
        let report: Report
    }

    enum DashboardId { case top, middle, bottom }

    private(set) var dashboards = [DashboardId: SKSpriteNode]()
    private(set) var emptyMonitorFactory: EmptyMonitorFactory!
    let layouts: [HudLayout: SKNode]
    let prototypes: Prototypes
    let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
        self.layouts = HUD.unpackLayouts(scene)
        self.prototypes = HUD.unpackPrototypes(scene)
        self.emptyMonitorFactory = EmptyMonitorFactory(hud: self)
    }

    func buildDashboards() {
        let dashboardsFactory = DashboardFactory(hud: self)

        let bottom = dashboardsFactory.newDashboard()
        let bx = bottom.size.width, by = -bottom.size.height
        bottom.position = CGPoint(x: bx, y: by)
        scene.addChild(bottom)

        let middle = dashboardsFactory.newDashboard()
        let mx = middle.size.width, my = CGFloat.zero
        middle.position = CGPoint(x: mx, y: my)
        scene.addChild(middle)

        dashboards[.middle] = middle
        dashboards[.bottom] = bottom
    }

    func placeDashoid(
        _ dashoid: SKSpriteNode, on dashboardId: DashboardId,
        quadrant: Int, layoutId: HudLayout
    ) {
        let layout = (layouts[layoutId])!
        dashoid.position =
            layout.children
                .filter({ $0.name != nil })
                .sorted(by: { $0.name! < $1.name! })[quadrant].position

        dashboards[dashboardId]!.addChild(dashoid)
    }

    private static func unpackLayouts(_ scene: SKScene) -> [HudLayout: SKNode] {
        return HudLayout.allCases.reduce(into: [:]) { result, prototypeId in
            result[prototypeId] =
                (scene.childNode(withName: prototypeId.rawValue) as? SKSpriteNode)!
        }
    }

    private static func unpackPrototypes(_ scene: SKScene) -> Prototypes {
        let bc = (scene.childNode(
            withName: HudPrototype.barchart_monitor_prototype.rawValue
        ) as? BarChart)!

        let db = (scene.childNode(
            withName: HudPrototype.dashboard_backer.rawValue
        ) as? SKSpriteNode)!

        let em = (scene.childNode(
            withName: HudPrototype.empty_monitor_prototype.rawValue
        ) as? SKSpriteNode)!

        let lg = (scene.childNode(
            withName: HudPrototype.linegraph_monitor_prototype.rawValue
        ) as? LineGraph)!

        let rp = (scene.childNode(
            withName: HudPrototype.report_monitor_prototype.rawValue
        ) as? Report)!

        return Prototypes(bc, db, em, lg, rp)
    }

    func getNetPortal() -> SKNode {
        return scene.childNode(withName: "net_portal")!
    }
}
