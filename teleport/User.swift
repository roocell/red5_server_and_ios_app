//
//  User.swift
//  teleport
//
//  Created by michael russell on 2016-11-20.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//

import Foundation
import MapKit

class User: NSObject, MKAnnotation {
    let uuid: String
    let coordinate: CLLocationCoordinate2D

    init(_ uuid: String, _ coordinate: CLLocationCoordinate2D) {
        self.uuid = uuid
        self.coordinate = coordinate        
        super.init()
    }


}
