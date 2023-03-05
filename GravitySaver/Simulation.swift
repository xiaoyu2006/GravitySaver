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
    
    func toCircle(radius: Double) -> NSBezierPath {
        return NSBezierPath(ovalIn: NSRect(x: self.x - radius, y: self.y - radius, width: radius * 2, height: radius * 2))
    }
}

class Planet {
    var pos: Vec2D
    var vel: Vec2D
    var radius: Double
    var mass: Double
    var color: NSColor
    
    init(pos: Vec2D, vel: Vec2D, radius: Double, mass: Double, color: NSColor) {
        self.pos = pos
        self.vel = vel
        self.radius = radius
        self.mass = mass
        self.color = color
    }
    
    convenience init(pos: Vec2D, radius: Double, mass: Double, color: NSColor) {
        self.init(pos: pos, vel: Vec2D(), radius: radius, mass: mass, color: color)
    }
    
    func drawPoint() {
        self.color.setFill()
        self.pos.toCircle(radius: self.radius).fill()
    }
    
    func updatePosition(deltaTime: Double) {
        self.pos = self.pos + (self.vel * deltaTime)
    }
    
    func applyForce(force: Vec2D, deltaTime: Double) {
        self.vel = self.vel + (force / mass) * deltaTime
    }
    
    func gravityTo(planet: Planet, G: Double) -> Vec2D {
        let posDiff = planet.pos - self.pos
        let forceMagnitude = G * self.mass * planet.mass / pow(posDiff.module(), 2)
        return posDiff.unitVec() * forceMagnitude
    }
    
    func applyPlanetGravity(planet: Planet, G: Double, deltaTime: Double) {
        let gForce = self.gravityTo(planet: planet, G: G)
        self.applyForce(force: gForce, deltaTime: deltaTime)
    }
}

class System {
    var planets: [Planet] = []
    var deltaTime: Double = 0.01
    var G: Double = 1
    
    static func defaultSystem() -> System {
        let system = System()
        system.addPlanet(Planet(pos: Vec2D(200, 200), radius: 20, mass: 1, color: NSColor.yellow))
        return system
    }
    
    func addPlanet(_ planet: Planet) {
        self.planets.append(planet)
    }
    
    func draw(_ bounds: NSRect) {
        NSColor.black.setFill()
        bounds.fill()
        
        for planet in self.planets {
            planet.drawPoint()
        }
    }
    
    func update() {
        self.updateVelocity()
        self.updatePosition()
    }
    
    private func updateVelocity() {
        for p1i in 0..<planets.count {
            for p2i in 0..<planets.count {
                if p1i != p2i {
                    let p1 = planets[p1i]
                    let p2 = planets[p2i]
                    p1.applyPlanetGravity(planet: p2, G: G, deltaTime: deltaTime)
                }
            }
        }
    }
    
    private func updatePosition() {
        for planet in planets {
            planet.updatePosition(deltaTime: deltaTime)
        }
    }
}
