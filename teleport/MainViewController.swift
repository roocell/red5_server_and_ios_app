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

class MainViewController: UIViewController, CLLocationManagerDelegate {
 
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


        mapView.showsUserLocation = true
        
        ServerComms().getUsers() { (results: Array) in
            print("\(#file):\(#line) \(results)")
            self.users.removeAll()
            for u  in results {
                let uu = u as! [String:AnyObject]  // need to make it a swift dictionary in order to use the subscript below
                //print("lat \(uu["lat"] as! NSString).doubleValue") // the coords are returned in the json as strings
                let coordinate = CLLocation(latitude: (uu["lat"] as! NSString).doubleValue, longitude: (uu["lon"] as! NSString).doubleValue)
                let user=User(uu["uuid"] as! String, coordinate.coordinate)
                self.users.append(user)
            }
            
            // trigger refresh of map
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.users)
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

    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            
        } else {
            // handle other annotations
            if let annotation = annotation as? User {
                let identifier = "pin"
                var view: MKPinAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                    as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                }
                return view
            }
            return nil
        }
        return nil
    }

    
    

    // TODO: move to ServerComms
    //https://grokswift.com/updating-nsurlsession-to-swift-3-0/
    //https://www.raywenderlich.com/120442/swift-json-tutorial  - json parsing with Gloss
    //https://developer.apple.com/swift/blog/?id=37
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    func updateUserLocation(_ location: CLLocation)
    {
        let appdel = UIApplication.shared.delegate as! AppDelegate
        if (appdel.uuid==nil)
        {
            return;
        }
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlStr: String = "http://roocell.homeip.net:11111/user.php?cmd=update&uuid=\(appdel.uuid!)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        print(urlStr)
        guard let url = URL(string: urlStr) else {
            print("Error: cannot creat URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            print("Entered user update completionHandler")
            
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = err as? NSError {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                        print(json)
                        let status = json["status"] as! String
                        let reason = json["reason"] as! String
                        print("status \(status) reason \(reason)")
                    } catch let error as NSError {
                            print(error)
                    }
                }
            }

        }.resume()

 
    }

    
    // Location Manager Delegate stuff
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }

    var initialMapCentered = false;
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        print(locationObj)
    
        self.updateUserLocation(locationObj);
        
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
