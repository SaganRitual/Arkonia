//
//  GameScene.swift
//  Components
//
//  Created by Rob Bishop on 4/15/19.
//  Copyright © 2019 Boring Software. All rights reserved.
//

import SpriteKit
import GameplayKit

class TheScene: SKScene {

    var entities = [GKEntity]()
    var graphs = [String: GKGraph]()

    private var lastUpdateTime: TimeInterval = 0

    override func sceneDidLoad() {

        self.lastUpdateTime = 0

        let atlas = SKTextureAtlas(named: "Sprites")
        spriteTexture = atlas.textureNamed("spark-aluminum-large")

        let sprite = SKSpriteNode(texture: spriteTexture)
        addChild(sprite)

    }

    func touchDown(atPoint pos: CGPoint) {
    }

    func touchMoved(toPoint pos: CGPoint) {
    }

    func touchUp(atPoint pos: CGPoint) {
    }

    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        // Initialize _lastUpdateTime if it has not already been
        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
            return
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        self.lastUpdateTime = currentTime
    }
}
