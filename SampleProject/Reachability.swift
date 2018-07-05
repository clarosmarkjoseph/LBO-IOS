//
//  Reachability.swift
//  SampleProject
//
//  Created by Admin on 18/05/2017.
//  Copyright © 2017 itadmin. All rights reserved.
//

import Foundation
import SystemConfiguration


public class Reachability {

    
    class func isConnectedToNetwork()->Bool{
        var Status:Bool = false
        let url = NSURL(string: "https://lbo-bare.com")
        let request = NSMutableURLRequest(url: url! as URL as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30.0
        var response: URLResponse?
        do
        {
             try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
        }
        catch
        {
            
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        else
        {
            Status = false
        }
        
        return Status
    }
    
    class func isConnectionTimeout()->Bool{
        var Status:Bool = false
        let url = NSURL(string: "https://system.lay-bare.com")
        let request = NSMutableURLRequest(url: url! as URL as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 7
        var response: URLResponse?
        do
        {
            try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
        }
        catch
        {
            
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        else
        {
            Status = false
        }
        return Status
    }
    
    class func ConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection
        
    }
    
    class func isWebViewReachable(webUrl:String)->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: webUrl)
        let request = NSMutableURLRequest(url: url! as URL as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 40.0
        var response: URLResponse?
        do
        {
            try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
        }
        catch
        {
            Status = false
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        else
        {
            Status = false
        }
        
        return Status
    }
}
