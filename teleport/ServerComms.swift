//
//  ServerComms.swift
//  teleport
//
//  Created by michael russell on 2016-11-20.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//
// this class exists to extract out all the comms with the server so we dont need all this NSSession stuff in each class
// all functions should use completion callbacks
// using swift - just because

// http://ericasadun.com/2014/08/21/swift-calling-swift-functions-from-objective-c/

import Foundation
import CoreLocation

class ServerComms: NSObject {

    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

    let baseurl: String = "http://roocell.homeip.net:11111/"
    
    // https://thatthinginswift.com/completion-handlers/
    
    func getJsonFromUrl(_ urlStr: String, completion: @escaping ([String: Any]) -> ())
    {
        print("\(type(of: self)):\(#line):\(urlStr)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let url = URL(string: urlStr) else {
            print("Error: cannot creat URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = err as? NSError {
                print(error.localizedDescription)
                return
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                        let status = json["status"] as! String // ! = definitely there and definitely a String
                        //let reason = json["reason"] as? String // ? = might be there and/or might be a String
                        
                        // assuming status is always returned regardless of url
                        if (status != "success")
                        {
                            print("\(#file):\(#function)\(#line) ERROR status \(status)");
                        }
                        //print("\(type(of: self)):\(#line)")
                        completion(json)
                    } catch let error as NSError {
                        print("\(type(of: self)):\(#line) \(error)")
                    }
                }
            }
            
        }.resume()
    }

    //http://blog.teamtreehouse.com/understanding-optionals-swift
    func verifyUuidAvailable () -> String? {
        let appdel = UIApplication.shared.delegate as! AppDelegate
        if (appdel.uuid==nil)
        {
            print("ERR ERR ERR: appdel.uuid does not exist yet");
            return nil
        }
        return appdel.uuid;
    }
    
    // return an array of all users and the associated data in the users table
    func getUsers(completion: @escaping (Array<Any>) -> ())
    {
        let url_ext: String = "user.php?cmd=getusers&uuid=\(verifyUuidAvailable()!)"
        let urlStr: String = "\(baseurl)\(url_ext)"
        getJsonFromUrl(urlStr) { (json: [String: Any]) in
            completion(json["data"] as! Array)
        }
    }

    //https://grokswift.com/updating-nsurlsession-to-swift-3-0/
    //https://www.raywenderlich.com/120442/swift-json-tutorial  - json parsing with Gloss
    //https://developer.apple.com/swift/blog/?id=37
    func updateUserLocation(_ location: CLLocation, completion: @escaping ([String: Any]) -> ())
    {
        let url_ext: String = "user.php?cmd=update&uuid=\(verifyUuidAvailable()!)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        let urlStr: String = "\(baseurl)\(url_ext)"
        getJsonFromUrl(urlStr) { (json: [String: Any]) in
            completion(json)
        }
    }
    
    func registerUser(_ apns_token: String, completion: @escaping ([String: AnyObject]) -> ())
    {
        let url_ext: String = "user.php?cmd=add&uuid=\(verifyUuidAvailable()!)&apns_token=\(apns_token)"
        let urlStr: String = "\(baseurl)\(url_ext)"
        getJsonFromUrl(urlStr) { (json: [String: Any]) in
            //print("\(type(of: self)):\(#line)")
            // registerUser is called from obj-c code
            // we want to pass back the json as an NSDictionary so we
            // need to unwrap to [String: AnyObject] which is equivalent to NSDictionary in obj-c
            completion(json as [String: AnyObject])
        }
    }

    func getServer(_ completion: @escaping ([String: AnyObject]) -> ())
    {
        let url_ext: String = "server.php"
        let urlStr: String = "\(baseurl)\(url_ext)"
        getJsonFromUrl(urlStr) { (json: [String: Any]) in
            completion(json as [String: AnyObject])
        }
    }

}
