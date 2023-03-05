//
//  GravitySaverView.swift
//  GravitySaver
//
//  Created by Kerman on 2023/3/3.
//

import ScreenSaver

class GravitySaverView: ScreenSaverView {
    
//    var configController = GravityConfigController()
    
    var system: System!
            
    static func genDefaultSystem(frame: CGRect) -> System {
        let system = System()
        system.addInfluencer(Planet(pos: Vec2D(frame.midX, frame.midY), vel: Vec2D(), radius: 10, mass: 200, fixed: true))
        
        func getRandomPos() -> Vec2D {
            let margin = 250.0
            let rXMin = margin, rXMax = frame.maxX - margin
            let rYMin = margin, rYMax = frame.maxY - margin
            return Vec2D(SSRandomFloatBetween(rXMin, rXMax), SSRandomFloatBetween(rYMin, rYMax))
        }
        
        func getRandomVelocity(_ pos: Vec2D) -> Vec2D {
            let middle = Vec2D(frame.midX, frame.midY)
            let toCenter = middle - pos
            // Clockwise rotate 90
            var velocity = Vec2D(toCenter.y, -toCenter.x).unitVec()
            // Randomize direction
            velocity = velocity + Vec2D(SSRandomFloatBetween(-0.5, 0.5), SSRandomFloatBetween(-0.5, 0.5))
            // Randomize speed
            velocity = (velocity / sqrt(toCenter.module())) * 40 * SSRandomFloatBetween(0.7, 1.5)
            return velocity
        }

        let radius = 1.5
        let mass = 0.1
        for _ in 0..<3000 {
            let pos = getRandomPos()
            let vel = getRandomVelocity(pos)
            system.addPassiver(Planet(
                pos: pos,
                vel: vel,
                radius: radius, mass: mass, fixed: false
            ))
        }
        return system
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        system = GravitySaverView.genDefaultSystem(frame: frame)
    }
    
//    override var hasConfigureSheet: Bool {
//        return true
//    }
//
//    override var configureSheet: NSWindow? {
//        return configController.window
//    }
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        system = GravitySaverView.genDefaultSystem(frame: frame)
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        func getColor(vel: Vec2D) -> NSColor {
            let multiplier = 1.0 / (vel.module() / 10.0 + 1.0)
            return NSColor(red: 1.0 * multiplier, green: 1.0 * multiplier, blue: 1.0, alpha: 1.0)
        }

        // Draw the state
        NSColor.black.setFill()
        bounds.fill()

        for planet in system.influencers {
            NSColor.systemYellow.setFill()
            planet.pos.toCircle(radius: planet.radius).fill()
        }

        for planet in system.passivers {
            getColor(vel: planet.vel).setFill()
            planet.pos.toCircle(radius: planet.radius).fill()
        }
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        // Update the "state" of the screensaver
        self.system.update()
        self.setNeedsDisplay(self.bounds)
    }
}
