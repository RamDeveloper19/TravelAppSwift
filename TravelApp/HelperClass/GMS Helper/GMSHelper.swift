//
//  GMSHelper.swift
//  TravelApp
//
//  Created by Ram kumar on 01/04/22.
//

import Foundation
import GoogleMaps
import GooglePlaces

public class AnimatedPolyLine: GMSPolyline {
    var animationPolyline = GMSPolyline()
    var animationPath = GMSMutablePath()
    var i: UInt = 0
    var timer: Timer?
    private var repeats:Bool?
    
    override init() {
        super.init()
    }
    deinit {
        print("de init called")
    }
    convenience init(_ points: String,repeats:Bool) {
        self.init()
        self.repeats = repeats
        self.path = GMSPath.init(fromEncodedPath: points)!
        
        self.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.strokeWidth = 4.0
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        let count = self.path!.count()
        
        let interval = count < 200 ? 0.001 : 0.000001
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
    }
    
    @objc func animatePolylinePath(_ sender:Timer) {
        
        if self.i < (self.path?.count())! {
            self.animationPath.add((self.path?.coordinate(at: self.i))!)
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = UIColor.black
            self.animationPolyline.strokeWidth = 4
            self.animationPolyline.map = self.map
            self.i += 1
        } else {
            if self.repeats ?? false {
                self.i = 0
                self.animationPath = GMSMutablePath()
                self.animationPolyline.map = nil
            }
            else {
                sender.invalidate()
                if self.timer != nil {
                    self.timer = nil
                }
            }
        }

    }
}
