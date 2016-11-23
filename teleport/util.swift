//
//  util.swift
//  teleport
//
//  Created by michael russell on 2016-11-21.
//  Copyright © 2016 ThumbGenius Software. All rights reserved.
//
// just create global functions here - nice! Swift...you're so cool

import Foundation

func fflprint (_ text: String, callingFunctionName: String = #function, callingFileName: String = #file)
{
    let theFileName = (callingFileName as NSString).lastPathComponent
    print("\(theFileName)-\(callingFunctionName):\(#line) \(text)")
}
