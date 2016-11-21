//
//  MainViewController.swift
//  teleport
//
//  Created by michael russell on 2016-11-18.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

// https://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
 
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    
    var users = [User]()
    

    // TGLog/TGMark
    // swift doesn't allow for macros - need to make them functions :(
    //func TGLog(_ message...)
    //{
    //    print("%s:%d %s", messsage...)
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // http://stackoverflow.com/questions/19042894/periodic-ios-background-location-updates
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 300
        locationManager.requestAlwaysAuthorization()

        mapView.delegate=self;
        mapView.showsUserLocation = true
        
        ServerComms().getUsers() { (results: Array) in
            //print("\(#file):\(#line) \(results)")
            self.users.removeAll()
            for u  in results {
                let uu = u as! [String:AnyObject]  // need to make it a swift dictionary in order to use the subscript below
                //print("lat \(uu["lat"] as! NSString).doubleValue") // the coords are returned in the json as strings
                let coordinate = CLLocation(latitude: (uu["lat"] as! NSString).doubleValue, longitude: (uu["lon"] as! NSString).doubleValue)
                let user=User(uu["uuid"] as! String, coordinate.coordinate)
                self.users.append(user)
            }
            
            // trigger refresh of map (must be done a main thread (ui thread))
            // http://stackoverflow.com/questions/37801370/how-do-i-dispatch-sync-dispatch-async-dispatch-after-etc-in-swift-3
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(self.users)
                //self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showExample (_ viewController: UIViewController)
    {
        let appdel = UIApplication.shared.delegate as! AppDelegate
        
        if (appdel.stream_server_ip == nil)
        {
            print("#function:#line", "No server!");
            return;
        }
        let view=UIView(frame: self.view.frame);
        viewController.view = view;
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func onPublish(_ sender: AnyObject) {
        let appdel = UIApplication.shared.delegate as! AppDelegate
        if (appdel.checkUUID()==false)
        {
            print("Cannot publish yet - no UUID");
            return;
        }
        self.showExample(PublishExample());

    }

    
    // MAPKIT FUNCTIONS

    
    @IBAction func zoomIn(_ sender: AnyObject) {
    }
    
    
    @IBAction func changeMapType(_ sender: AnyObject) {
    }
    
  
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        print("\(type(of: self)):\(#function):\(#line)");
    }

    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            
        } else {
            //print("\(#file):\(#function)\(#line)");
            // handle other annotations
            let identifier = "User"
            
            if annotation.isKind(of:User.self) {
                if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                    annotationView.annotation = annotation
                    return annotationView
                } else {
                    let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                    annotationView.isEnabled = true
                    annotationView.canShowCallout = true
                    
                    let btn = UIButton(type: .detailDisclosure)
                    annotationView.rightCalloutAccessoryView = btn
                    return annotationView
                }
            }
        }

        return nil
    }

    
    
    
    // Location Manager Delegate stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }

    var initialMapCentered = false;
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        //print(locationObj)
    
        ServerComms().updateUserLocation(locationObj) { (results: [String: Any]) in
            
        }
        
        if (!initialMapCentered)
        {
            print("centering map just one time")
            centerMapOnLocation(locationObj)
            initialMapCentered=true
        }

    }
    
    // authorization status
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        var shouldIAllow = false
        
        switch status {
            case CLAuthorizationStatus.restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.notDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LabelHasbeenUpdated"), object: nil)
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }

}
