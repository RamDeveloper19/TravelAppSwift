//
//  TravelView.swift
//  TravelApp
//
//  Created by Ram kumar on 01/04/22.
//

import UIKit
import GoogleMaps

class TravelView: UIView {

    let mapview = GMSMapView()

    var layoutDict = [String: AnyObject]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(Base baseView: UIView) {

        baseView.backgroundColor = .white
        
        if let styleURL = Bundle.main.url(forResource: "mapStyleUber", withExtension: "json") {
            self.mapview.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        }
        
        mapview.settings.myLocationButton = false
        mapview.isMyLocationEnabled = false
        layoutDict["mapview"] = mapview
        mapview.translatesAutoresizingMaskIntoConstraints = false
        baseView.addSubview(mapview)
        
        
        mapview.topAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        mapview.bottomAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapview]|", options: [], metrics: nil, views: layoutDict))

        
    }

}
