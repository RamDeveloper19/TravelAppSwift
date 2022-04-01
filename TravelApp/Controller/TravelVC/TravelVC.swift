//
//  TravelVC.swift
//  TravelApp
//
//  Created by Ram kumar on 01/04/22.
//

import UIKit
import Alamofire
import GoogleMaps
import GooglePlaces

class TravelVC: UIViewController {

    let travelView = TravelView()

    var travelCoordinates : KeyValuePairs<String, CLLocationCoordinate2D> {
        return ["Kochi": (CLLocationCoordinate2D(latitude: 9.9312, longitude: 76.2673)),
                "Coimbatore": (CLLocationCoordinate2D(latitude: 11.0168, longitude: 76.9558)),
                "Madurai": (CLLocationCoordinate2D(latitude: 9.9252, longitude: 78.1198)),
                "Munnar": (CLLocationCoordinate2D(latitude: 10.0889, longitude: 77.0595)),
                "Kochi": (CLLocationCoordinate2D(latitude: 9.9312, longitude: 76.2673))
                
        ]
    }
    var animatedPolyline: AnimatedPolyLine!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupViews() {
        travelView.setupViews(Base: self.view)
        travelView.mapview.delegate = self
    }
    
    func setupData() {
        self.addStaticMarkers()
        self.getPolylinePointsRoute(points: self.travelCoordinates)
        
    }

}

extension TravelVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print(gesture)
    }
}

extension TravelVC {
    func addStaticMarkers() {
        self.travelCoordinates.forEach({
            let mark = GMSMarker()
            mark.icon = UIImage(named: "TravelIcon")
            mark.title = $0.key
            mark.position = CLLocationCoordinate2D(latitude: $0.value.latitude, longitude: $0.value.longitude)
            mark.isFlat = true
            mark.map = travelView.mapview
            travelView.mapview.selectedMarker = mark
        })
    }
}
extension TravelVC {
    
    func getPolylinePointsRoute(points: KeyValuePairs<String, CLLocationCoordinate2D>) {
        
        var parameterDict = [String : String]()
        
        if let pointFirst = points.first(where: {$0.key == "Kochi"}) {
            parameterDict["origin"]  = "\(pointFirst.value.latitude),\(pointFirst.value.longitude)"
        }
        if let pointLast = points.first(where: {$0.key == "Kochi"}) {
            parameterDict["destination"] = "\(pointLast.value.latitude),\(pointLast.value.longitude)"
        }
        
        var wayPoints = ""
        for point in points {
            if point.key != "Kochi" {
                wayPoints = wayPoints == "" ? "\(point.value.latitude),\(point.value.longitude)" : "\(wayPoints)|\(point.value.latitude),\(point.value.longitude)"
            }
        }
        parameterDict["waypoints"] = wayPoints
        parameterDict["key"] = Helper.shared.googleMapKey
        let request = "https://maps.googleapis.com/maps/api/directions/json"
        print("URL , ParamDict", request,parameterDict)
        
        Alamofire.request(request, method: .get, parameters : parameterDict).responseJSON { response in
            if case .failure(let error) = response.result {
                print(error.localizedDescription)
            } else if case .success = response.result {
                
                if let JSON = response.result.value as? [String:AnyObject], let status = JSON["status"] as? String {
                    if status == "OK" {
                        if let routes = JSON["routes"] as? [[String:AnyObject]], let route = routes.first {
                            if let overViewPoly = route["overview_polyline"] as? [String: AnyObject] {
                                if let points = overViewPoly["points"] as? String {
                                    
                                    DispatchQueue.main.async {
                                        self.animatedPolyline = AnimatedPolyLine(points,repeats:false)
                                        let bounds = GMSCoordinateBounds(path: self.animatedPolyline.path!)
                                        self.travelView.mapview.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 200, left: 20, bottom: self.view?.center.y ?? 150, right: 20)))
                                        self.animatedPolyline.map = self.travelView.mapview
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
