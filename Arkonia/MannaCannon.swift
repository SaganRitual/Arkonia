import SpriteKit

class MannaCannon {
    static var shared: MannaCannon?

    static let mannaPlaneQueue = DispatchQueue(
        label: "manna.plane.serial", target: DispatchQueue.global()
    )
    private var readyMannaIndices: Cbuffer<Int>

    let readyMannaBatchSize = 10
    let pollenators: [Pollenator]

    var cDeadManna = 0
    var cPhotosynthesizingManna = 0
    var cPlantedManna = 0

    init() {
        readyMannaIndices = .init(cElements: Arkonia.cMannaMorsels)

        if Arkonia.cPollenators == 0 { pollenators = []; return }

        // Colors for bone, ham, leather, oxygen, ooze pollenators
        let colors: [SKColor] = [.white, .purple, .yellow, .blue, .green]
        pollenators = colors.map { Pollenator($0) }
    }

    func blast(_ manna: Manna) {
        MannaCannon.mannaPlaneQueue.async {
            [readyMannaBatchSize, readyMannaIndices] in

            readyMannaIndices.pushBack(manna.absoluteGridIndex)

            if readyMannaIndices.count > readyMannaBatchSize {
                let min_ = Arkonia.mannaRebloomDelayMinimum
                let max_ = Arkonia.mannaRebloomDelayMaximum
                let duration = TimeInterval.random(in: min_..<max_)

                let cMannaToLaunch = min(readyMannaIndices.count, readyMannaBatchSize)

                let mannaToLaunch: [Manna] = (0..<cMannaToLaunch).map { _ in
                    let absoluteMannaIndex = readyMannaIndices.popFront()
                    return Grid.mannaAt(absoluteMannaIndex)!
                }

                MannaCannon.mannaPlaneQueue.asyncAfter(deadline: .now() + duration) {
                    SceneDispatch.shared.schedule {
                        mannaToLaunch.forEach { $0.rebloom() }
                    }
                }
            }
        }
    }

    func postInit() {
        // Indiscriminately attempt to plant as many manna as indicated. Since
        // we're choosing a random cell each time, we'll sometimes pick a cell
        // that already has manna in it, in which case we try to find an open
        // cell among the eight cells surrounding the chosen random cell. If we
        // can't place manna in any of these nine cells, skip the attempt. The
        // result is that we'll usually end up with fewer than cMannaMorsels morsels
        for _ in 0..<Arkonia.cMannaMorsels {
            let centerGridCell = Grid.randomCell()

            guard let newMannaHome = getEmptyCell(startingAt: centerGridCell) else { continue }

            let absoluteIx = newMannaHome.properties.gridAbsoluteIndex

            let m = Grid.plantManna(at: absoluteIx)
            m.sprite.firstBloom(at: absoluteIx)

            cPlantedManna += 1
        }
    }

    private func getEmptyCell(startingAt centerGridCell: GridCell) -> GridCell? {
        if let (targetCell, _) = Grid.first(
            fromCenterAt: centerGridCell, cCells: 9, where: { candidateCell, _ in
            !candidateCell.contents.hasManna()
        }) { return targetCell }

        return nil
    }
}
