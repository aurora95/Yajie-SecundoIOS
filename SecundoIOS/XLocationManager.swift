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
                if tcpClient.isClientInitialized == false{
                    msg.msgType = XMSG_INIT
                    msg.userID = tcpClient.clientID
                    msg.data.loc.latitude = currentLocation!.coordinate.latitude
                    msg.data.loc.longitude = currentLocation!.coordinate.longitude
                    msg.data.skin = settingsUserSkin
                    tcpClient.SendString(msg.toJSON())
                    tcpClient.isClientInitialized = true
                } else{
                    msg.msgType = XMSG_MOVE
                    msg.userID = tcpClient.clientID
                    msg.data.loc.latitude = currentLocation!.coordinate.latitude
                    msg.data.loc.longitude = currentLocation!.coordinate.longitude
                    tcpClient.SendString(msg.toJSON())
                }
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
        locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager!.startUpdatingLocation()
    }
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation?.coordinate.latitude == locations.last?.coordinate.latitude
            && currentLocation?.coordinate.longitude == locations.last?.coordinate.longitude{
            //do nothing
        } else{
            currentLocation = locations.last!
        }
    }
    
    @objc func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.LocationError, object: nil)
    }
}
