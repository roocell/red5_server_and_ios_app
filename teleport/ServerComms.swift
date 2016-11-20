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

class ServerComms: NSObject {

    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?  // ummm....this should probably be a queue of some sort because we'll have many callers?

    let baseurl: String = "http://roocell.homeip.net:11111/"
    
    // https://thatthinginswift.com/completion-handlers/
    
    // return an array of all users and the associated data in the users table
    func getUsers(completion: @escaping (Array<Any>) -> ())
    {
        let appdel = UIApplication.shared.delegate as! AppDelegate
        if (appdel.uuid==nil)
        {
            print("ERR ERR ERR: appdel.uuid does not exist yet");
            return;
        }

        let url_ext: String = "user.php?cmd=getusers&uuid=\(appdel.uuid!)"
        let urlStr: String = "\(baseurl)\(url_ext)"
        print("\(#file):\(#line) \(urlStr)")

        // TODO: not good for multiple callers - need to implement a queue
        if dataTask != nil {
            dataTask?.cancel()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let url = URL(string: urlStr) else {
            print("Error: cannot creat URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if let error = err as? NSError {
                print(error.localizedDescription)
                return 
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                        print(json)
                        let status = json["status"] as! String // ! = definitely there and definitely a String
                        let reason = json["reason"] as? String // ? = might be there and/or might be a String
                        
                        
                        print("status \(status) reason \(reason)")
                        
                        completion(json["data"] as! Array)
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            
        }.resume()
    }
}
