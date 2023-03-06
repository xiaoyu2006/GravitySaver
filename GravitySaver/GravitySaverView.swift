//
//  GravitySaverView.swift
//  GravitySaver
//
//  Created by Kerman on 2023/3/3.
//

import ScreenSaver


extension Vec2D {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    
    func toCircle(radius: Double) -> NSBezierPath {
        return NSBezierPath(ovalIn: NSRect(x: self.x - radius, y: self.y - radius, width: radius * 2, height: radius * 2))
    }
}

class GravitySaverView: ScreenSaverView {
    
    //    var configController = GravityConfigController()
    
    var system: System!
    var traces: [[Vec2D]]!
    
    static let SIZE = 2000
    
    
    static func genDefaultSystem(frame: CGRect) -> System {
        let system = System()
        system.addInfluencer(Planet(pos: Vec2D(frame.midX - 20.0, frame.midY), vel: Vec2D(0, -2.0), radius: 8.0, mass: 100.0, fixed: false))
        system.addInfluencer(Planet(pos: Vec2D(frame.midX + 20.0, frame.midY), vel: Vec2D(0, 2.0), radius: 8.0, mass: 100.0, fixed: false))
        
        func getRandomPos() -> Vec2D {
            let margin = 200.0
            let rXMin = margin, rXMax = frame.maxX - margin
            let rYMin = margin, rYMax = frame.maxY - margin
            
            var x = SSRandomFloatBetween(rXMin, rXMax)
            var y = SSRandomFloatBetween(rYMin, rYMax)
            
            // Move away from center
            let MIN_DIST = 100.0
            let distXToCenter = x - frame.midX
            let distYToCenter = y - frame.midY
            if sqrt(pow(distXToCenter, 2) + pow(distYToCenter, 2)) < MIN_DIST {
                if distXToCenter > 0.0 { x += MIN_DIST }
                else { x -= MIN_DIST }
                if distYToCenter > 0.0 { y += MIN_DIST }
                else { y -= MIN_DIST }
            }
            
            return Vec2D(x, y)
        }
        
        func getRandomVelocity(_ pos: Vec2D) -> Vec2D {
            let middle = Vec2D(frame.midX, frame.midY)
            let toCenter = middle - pos
            let dist = toCenter.module()
            
            // Clockwise rotate 90
            var velocity = Vec2D(toCenter.y, -toCenter.x).unitVec()
            
            // Randomize direction
            velocity = velocity + Vec2D(SSRandomFloatBetween(-0.3, 0.3), SSRandomFloatBetween(-0.3, 0.3))
            
            velocity = velocity * sqrt(1 / dist) * 44.0
            // Randomize speed
            velocity = velocity * SSRandomFloatBetween(0.8, 1.2)
            
            return velocity
        }
        
        let radius = 2.0
        let mass = 0.1
        for _ in 0..<SIZE {
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
    
    fileprivate func initSystem(_ frame: NSRect) {
        system = GravitySaverView.genDefaultSystem(frame: frame)
        traces = [[Vec2D]](repeating: [], count: GravitySaverView.SIZE)
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        initSystem(frame)
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
        
        for planetIndex in 0..<system.passivers.count {
            let planet = system.passivers[planetIndex]
            
            // Update and draw traces
            traces[planetIndex].append(planet.pos)
            if traces[planetIndex].count > 6 {
                traces[planetIndex].removeFirst()
            }
            let path = NSBezierPath()
            for (i, point) in traces[planetIndex].enumerated() {
                let alpha = CGFloat(i) / CGFloat(traces[planetIndex].count)
                NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha).setStroke()
                if i == 0 {
                    path.move(to: point.toCGPoint())
                } else {
                    path.line(to: point.toCGPoint())
                }
            }
            path.lineWidth = 1.5
            path.stroke()
            
            // Draw the planet itself
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
