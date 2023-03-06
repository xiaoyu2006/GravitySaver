//
//  Simulation.swift
//  GravitySaver
//
//  Created by Kerman on 2023/3/5.
//

import Foundation
import Cocoa

struct Vec2D {
    var x, y: Double
    
    init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }
    
    init() {
        self.x = 0
        self.y = 0
    }
    
    init(_ cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
    
    func module() -> Double {
        return sqrt(
            pow(self.x, 2) + pow(self.y, 2)
        )
    }
    
    func unitVec() -> Vec2D {
        return self / self.module()
    }
    
    func distanceTo(rhs: Vec2D) -> Double {
        let d = self - rhs
        return d.module()
    }
    
    static func + (lhs: Vec2D, rhs: Vec2D) -> Vec2D {
        return Vec2D(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func - (lhs: Vec2D, rhs: Vec2D) -> Vec2D {
        return Vec2D(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    static func * (lhs: Vec2D, rhs: Double) -> Vec2D {
        return Vec2D(lhs.x * rhs, lhs.y * rhs)
    }
    
    
    static func / (lhs: Vec2D, rhs: Double) -> Vec2D {
        return Vec2D(lhs.x / rhs, lhs.y / rhs)
    }
}

class Planet {
    var pos: Vec2D
    var vel: Vec2D
    var radius: Double
    var mass: Double
    var fixed: Bool
    
    init(pos: Vec2D, vel: Vec2D, radius: Double, mass: Double, fixed: Bool) {
        self.pos = pos
        self.vel = vel
        self.radius = radius
        self.mass = mass
        self.fixed = fixed
    }

    func updatePosition(deltaTime: Double) {
        if fixed { return }
        self.pos = self.pos + (self.vel * deltaTime)
    }
    
    func applyForce(force: Vec2D, deltaTime: Double) {
        self.vel = self.vel + (force / mass) * deltaTime
    }
    
    func gravityTo(planet: Planet, G: Double) -> Vec2D {
        let posDiff = planet.pos - self.pos
        
        let MIN_DIST = 40.0  // Nasty hack
        var dist = posDiff.module()
        if dist < MIN_DIST { dist = MIN_DIST }

        let forceMagnitude = G * self.mass * planet.mass / pow(dist, 2)
        return posDiff.unitVec() * forceMagnitude
    }
    
    func applyPlanetGravity(planet: Planet, G: Double, deltaTime: Double) {
        let gForce = self.gravityTo(planet: planet, G: G)
        self.applyForce(force: gForce, deltaTime: deltaTime)
    }
}

class System {
    var influencers: [Planet] = []
    var passivers: [Planet] = []
    var deltaTime: Double = 0.5
    var G: Double = 10
    
    func addInfluencer(_ planet: Planet) {
        self.influencers.append(planet)
    }
    
    func addPassiver(_ planet: Planet) {
        self.passivers.append(planet)
    }
    
    func update() {
        self.updateVelocity()
        self.updatePosition()
    }
    
    private func updateVelocity() {
        for i1 in influencers {
            for i2 in influencers {
                if i1 === i2 { continue }
                i1.applyPlanetGravity(planet: i2, G: G, deltaTime: deltaTime)
            }
        }
        
        for influencer in influencers {
            for passiver in passivers {
                passiver.applyPlanetGravity(planet: influencer, G: G, deltaTime: deltaTime)
            }
        }
    }
    
    private func updatePosition() {
        for planet in influencers {
            planet.updatePosition(deltaTime: deltaTime)
        }
        
        for planet in passivers {
            planet.updatePosition(deltaTime: deltaTime)
        }
    }
}
