//
//  TCPClient.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/9/25.
//  Copyright (c) 2015年 Yajie Xing. All rights reserved.
//

import Foundation

class TCPClient{
    let serverIP = "115.159.38.35"
    let port = 6666
    let timeout = 5.0
    let bufferSize = 1024
    let clientQ = dispatch_queue_create("com.secundo.tcpclient", DISPATCH_QUEUE_SERIAL)
    
    var streamError = Bool(false){
        didSet{
            if streamError == true{
                let delayInSeconds = 5.0
                let delay = Int64(delayInSeconds*Double(NSEC_PER_MSEC))
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay)
                dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.StreamError, object: nil)
                }
            }
        }
    }
    struct Notification{
        static let StreamError = "TCPClient.Notification.StreamError"
    }
    
    var clientID = 0
    var isClientInitialized = false
    var messageHandler: XMessageHandler!
    var locationManager: XLocationManager!
    var socketContext = CFSocketContext()
    var socket: CFSocket!
    
    
    init(){
        messageHandler = XMessageHandler(owner: self)
        //create socket
        socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, CFSocketCallBackType.ReadCallBack.rawValue | CFSocketCallBackType.ConnectCallBack.rawValue, ClientSocketReadCallBack, &socketContext)
        //set socket flags
        //var sockopt = CFSocketGetSocketFlags(socket)
        //sockopt |= kCFSocketAutomaticallyReenableReadCallBack
        //CFSocketSetSocketFlags(socket, sockopt)
        //
        let qos = Int(QOS_CLASS_UTILITY.rawValue)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue){
            self.MainWork()
        }
        //set address
        var serveraddr = GetSockAddr(NSString(string: serverIP).cStringUsingEncoding(NSUTF8StringEncoding), Int32(port))
        let serveraddrData = CFDataCreate(kCFAllocatorDefault, TransSockAddrToBytes(&serveraddr), Int(SizeOfSockAddr()))
        //CFSocketSetAddress(socket, serveraddrData)
        CFSocketConnectToAddress(socket, serveraddrData, 5.0)
        
        
        
        locationManager = XLocationManager(client: self)
        
    }
 
    func MainWork(){
        CFRunLoopAddSource(CFRunLoopGetCurrent(), CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 1), kCFRunLoopDefaultMode)
        CFRunLoopRun()
    }
    
    func SendString(stringToSend: String){
        dispatch_async(clientQ){
            let buf = NSMutableData(capacity: self.bufferSize)
            let buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
            stringToSend.dataUsingEncoding(NSUTF8StringEncoding)!.getBytes(UnsafeMutablePointer<Void>(buffer), length: stringToSend.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            
            
            print("Send: ", stringToSend)
        }
    }
}

func ClientSocketReadCallBack(sock:CFSocket!, _ callbacktype:CFSocketCallBackType, _ address:CFData!, _ data:UnsafePointer<Void>, _ info:UnsafeMutablePointer<Void>) -> Void{
    if callbacktype == CFSocketCallBackType.AcceptCallBack{
        print("connection failed\n")
    }
    else if callbacktype == CFSocketCallBackType.ReadCallBack{
        
    }
}








