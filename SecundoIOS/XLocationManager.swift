//
//  XLocationManager.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/10/17.
//  Copyright © 2015年 Yajie Xing. All rights reserved.
//

import Foundation
import CoreLocation

class XLocationManager:NSObject, CLLocationManagerDelegate
{
    weak var tcpClient: TCPClient!
    var status : CLAuthorizationStatus?
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?{
        didSet{
            if currentLocation != nil{
                let msg = XMessage()
                msg.msgType = XMSG_MOVE
                msg.userID = tcpClient.clientID!
                msg.data.loc.latitude = currentLocation!.coordinate.latitude
                msg.data.loc.longitude = currentLocation!.coordinate.longitude
                tcpClient.SendString(msg.toJSON())
            }
        }
    }
    
    struct Notification{
        static let LocationError = "XLocationManager.Notification.LocationError"
    }
    
    init(client: TCPClient!){
        super.init()
        tcpClient = client
        status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Denied
            || status == CLAuthorizationStatus.Restricted {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocationError, object: nil)
        }
        locationManager = CLLocationManager()
        locationManager!.requestAlwaysAuthorization()
        locationManager!.delegate = self
        if status == CLAuthorizationStatus.NotDetermined{
            locationManager!.requestAlwaysAuthorization()
        }
        if !CLLocationManager.locationServicesEnabled(){
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocationError, object: nil)
        }
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.startUpdatingLocation()
    }
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
    }
    
    @objc func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocationError, object: nil)
    }
}
