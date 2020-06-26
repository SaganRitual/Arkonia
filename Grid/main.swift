//
//  main.swift
//  GridMock
//
//  Created by Rob Bishop on 6/27/20.
//  Copyright © 2020 Boring Software. All rights reserved.
//

import Foundation

print("Hello, World!")

Grid.makeGrid(
    cellDimensionsPix: CGSize(width: 100, height: 100),
    portalDimensionsPix: CGSize(width: 500, height: 500),
    maxCSenseRings: 10, funkyCellsMultiplier: nil
)

for _ in 0..<10 {
    let p = Grid.randomCell()
    Debug.log(level: 210) { "\(p)" }
}

let q = Grid.cellAt(AKPoint(-2, 2))
Debug.log(level: 210) {
    "Grid: \(q.properties.gridPosition)"
    + ", Scene: \(q.properties.scenePosition)"
    + ", Index: \(q.properties.gridAbsoluteIndex)"
}

for localIx in 1..<9 {
    let (cell, isAdjusted) = Grid.cellAt(localIx, from: q)
    Debug.log(level: 210) {
        "Cell at local \(localIx): \(cell.properties.gridPosition)"
        + ", isAdjusted \(isAdjusted)"
        + ", Scene: \(cell.properties.scenePosition)"
        + ", AbsIndex: \(cell.properties.gridAbsoluteIndex)"
    }
}

func engageGrid() {
    MainDispatchQueue.async {
        Debug.log(level: 206) { "engageGrid" }
        Debug.debugColor(self, .red, .yellow)

        let requester = self.sensorPad.center
        SensorPad.Engage.engageSensors(
            self.sensorPad, for: ., centeredAt: <#T##AKPoint#>, <#T##onComplete: () -> Void##() -> Void#>

        )
    }
}

Debug.waitForLogToClear()
