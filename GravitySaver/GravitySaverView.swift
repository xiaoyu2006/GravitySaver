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
    
    static func defaultSystem(frame: CGRect) -> System {
        let system = System()
        system.addInfluencer(Planet(pos: Vec2D(frame.midX, frame.midY), vel: Vec2D(), radius: 10, mass: 200, color: NSColor.yellow, fixed: true))
        
        let radius = 1.5
        let mass = 0.1
        let color = NSColor.white
        for _ in 0..<2000 {
            let rXMin = frame.midX - 200.0, rXMax = frame.midX + 200.0
            let rYMin = 150.0, rYMax = frame.midY - 100.0
            system.addPassiver(Planet(
                pos: Vec2D(SSRandomFloatBetween(rXMin, rXMax), SSRandomFloatBetween(rYMin, rYMax)),
                vel: Vec2D(SSRandomFloatBetween(0.5, 3), SSRandomFloatBetween(-0.1, 0.1)),
                radius: radius, mass: mass, color: color, fixed: false
            ))
        }
        return system
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        system = GravitySaverView.defaultSystem(frame: frame)
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
        system = GravitySaverView.defaultSystem(frame: frame)
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
   
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw the state
        system.draw(self.bounds)
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        // Update the "state" of the screensaver
        self.system.update()
        self.setNeedsDisplay(self.bounds)
    }
}
