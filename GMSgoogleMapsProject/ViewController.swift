//
//  ViewController.swift
//  GMSgoogleMapsProject
//
//  Created by Abdulaziz Alharbi on 14/12/1441 AH.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit


class ViewController: UIViewController, UIGestureRecognizerDelegate, GMSMapViewDelegate {
    
    var googleMapView: GMSMapView!
    var locationManager = CLLocationManager()
    
    var userCurrentLocation = CLLocation()
    
    var gesture = UILongPressGestureRecognizer()
    
    var zoomLevel: Float = 15
    
    var pinCurrentAdress: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        let cameraPosition = GMSCameraPosition(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0), zoom: zoomLevel)
        googleMapView = GMSMapView(frame: self.view.bounds, camera: cameraPosition)
        googleMapView.delegate = self
//        gesture.addTarget(self, action: #selector(didTouchMap(sender:)))
       
        gesture.allowableMovement = 100
        gesture.minimumPressDuration = 1
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 0


        gesture.delegate = self



        self.googleMapView.addGestureRecognizer(gesture)
        self.view.addSubview(googleMapView)
       
        checkIfUserUnableLocationService()

        
    }
    
    func checkIfUserUnableLocationService(){
        
        if CLLocationManager.locationServicesEnabled(){
            checkTheStatusOfUserLocationAuth()
        }else{
            print("location services is unable")
        }
        
    }
    
    func checkTheStatusOfUserLocationAuth(){
        
        switch CLLocationManager.authorizationStatus(){
        
        case .authorizedAlways:
            userCurrentLocation = locationManager.location!
            showUserLocationAfterGettingIt(userLocation: userCurrentLocation)
            break
        case .authorizedWhenInUse:
            if let userCurrentLocation = locationManager.location{
            showUserLocationAfterGettingIt(userLocation: userCurrentLocation)
            }
            break
        case .notDetermined:
   //         locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
            if let userCurrentLocation = locationManager.location{
            showUserLocationAfterGettingIt(userLocation: userCurrentLocation)
            }
            break
        case .restricted:
            print("your location is restricted")
            break
        case .denied:
            print("you have denied location access")
            break
        @unknown default:
            print("the case is a new cases that has not been covered")
        }
        
    }
    
    func showUserLocationAfterGettingIt(userLocation: CLLocation){
        var location2D = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        googleMapView.animate(toLocation: location2D)
        googleMapView.isTrafficEnabled = true
        googleMapView.isMyLocationEnabled = true
        
        print("We are inside showUserLocationAfterGettingIt")
    }
    
    func coordinateToAddress(markerLocation:CLLocationCoordinate2D, completionHandler: @escaping (String?) -> ()){
    
        self.pinCurrentAdress = "Empty Location"
        
        var geoCoder = GMSGeocoder()
       
            geoCoder.reverseGeocodeCoordinate(markerLocation) { (response, error) in

                if let markerLocation = response?.firstResult(){
                    var thoroughfare = markerLocation.thoroughfare ?? " "
                    var subLocality = markerLocation.subLocality ?? " "
                    self.pinCurrentAdress = "\(thoroughfare) \(subLocality)"
                    completionHandler(self.pinCurrentAdress)
                  
                }else{
                    
                    completionHandler(nil)
                }
                
            }
     
        }
    
//    @objc func didTouchMap(sender: UILongPressGestureRecognizer){
//        print("We are inside didTouchMap")
//        var locationInPoint = sender.location(in: googleMapView)
//        var touchCoordinate = googleMapView.conv
//
//        print("touch coordinate is: \(touchCoordinate)")
//
//   }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        self.googleMapView.clear()
        
        var marker = GMSMarker(position: coordinate)
        coordinateToAddress(markerLocation: coordinate) { (pinLocation) in
            
            DispatchQueue.main.async {
                if pinLocation != nil {
                marker.title = self.pinCurrentAdress
                marker.map = self.googleMapView
                }else {
                    marker.title = "No Location Specified by GM"
                    marker.map = self.googleMapView
                }
            }
            
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
       
        self.googleMapView.clear()
        
        var marker = GMSMarker(position: coordinate)
        coordinateToAddress(markerLocation: coordinate) { (pinLocation) in
            
            DispatchQueue.main.async {
                if pinLocation != nil {
                marker.title = self.pinCurrentAdress
                marker.map = self.googleMapView
                }else {
                    marker.title = "No Location Specified by GM"
                    marker.map = self.googleMapView
                }
            }
            
        }

        
        }
        
    }
    
    



