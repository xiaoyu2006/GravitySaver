//
//  GravitySaverView.swift
//  GravitySaver
//
//  Created by Kerman on 2023/3/3.
//

import ScreenSaver

class Gravity: ScreenSaverView {
    
//    var configController = GravityConfigController()
    
    let system = System.defaultSystem()
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
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
