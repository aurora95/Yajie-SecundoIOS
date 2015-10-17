//
//  ViewController.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/9/25.
//  Copyright (c) 2015年 Yajie Xing. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController
{
    
    var tcpClient = TCPClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "StreamErrorAlert:",
            name: TCPClient.Notification.StreamError,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "LocationErrorAlert:",
            name: XLocationManager.Notification.LocationError,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func StreamErrorAlert(notification: NSNotification){
        let alert = UIAlertController(title: "Network error!", message: "Cannot open read stream. Please restart the APP.", preferredStyle: UIAlertControllerStyle.Alert
        )
        ErrorAlert(alert)
    }
    
    func LocationErrorAlert(notification: NSNotification){
        let alert = UIAlertController(title: "Cannot get your location!", message: "Please check your settings", preferredStyle: UIAlertControllerStyle.Alert
        )
        ErrorAlert(alert)
    }
    
    func ErrorAlert(alert: UIAlertController){
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Cancel)
            {
                (action: UIAlertAction) -> Void in
                //
            }
        )
        presentViewController(alert, animated: true, completion: nil)
    }
}





