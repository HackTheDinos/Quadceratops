//
//  GameViewController.swift
//  HeadsUpDino
//
//  Created by Samantha John on 11/22/15.
//  Copyright © 2015 Quadceratops. All rights reserved.
//

import UIKit
import CoreMotion

class GameViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    var timeLeft = 60
    var dinoIsShown = false
    let dinos = Dinos()

    let gameView = DinoCardView(frame: CGRect.zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(gameView)

        self.showDino()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { (data, error) -> Void in
            self.getAccelerometerData(data)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick:", userInfo: nil, repeats: true)
    }
    
    func tick(timer: NSTimer) {
        if (timeLeft > 0) {
            self.gameView.timerLabel.text = "\(timeLeft)"
            timeLeft--
        } else {
            timer.invalidate()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func getAccelerometerData(data: CMAccelerometerData?) {
        let tolerance = 0.9
        if let z = data?.acceleration.z where fabs(z) > tolerance {
            if z > 0 {
                self.gameView.titleLabel.text = "CORRECT"
                self.gameView.background.backgroundColor = UIColor.QGreen()
                dinos.correct()
                
            } else {
                self.gameView.titleLabel.text = "Pass"
                self.gameView.background.backgroundColor = UIColor.QOrange()
                dinos.passed()
            }
            self.gameView.hideImage()
            gameView.subtitle.text = ""
            dinoIsShown = false
        } else if let z = data?.acceleration.z where fabs(z) < tolerance * 0.5 {
            self.showDino()
        }
    }
    
    func showDino() {
        if (dinoIsShown) {
            return
        }
        
        dinos.getNextDino()
        self.dinoIsShown = true
        if let dino = dinos.currentDino {
            gameView.titleLabel.text = dino.name
            gameView.subtitle.text = dino.tagline
            gameView.showImage(dino.imageName)
        }
        gameView.background.backgroundColor = UIColor.QBlue()
        gameView.setNeedsLayout()
        gameView.layoutIfNeeded()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopAccelerometerUpdates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gameView.frame = self.view.bounds
    }

}
