//
//  TCPClient.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/9/25.
//  Copyright (c) 2015年 Yajie Xing. All rights reserved.
//

import Foundation

enum ClientStatus{
    case none
    case connected
    case initializing
    case initialized
    case streamError
}

class TCPClientContext{
    
    let bufferSize = 1024
    let clientQ = dispatch_queue_create("com.secundo.tcpclient", DISPATCH_QUEUE_SERIAL)
    
    struct Notification{
        static let StreamError = "TCPClientContext.Notification.StreamError"
    }
    
    var readStream : CFReadStream?
    var writeStream: CFWriteStream?
    var readStreamContext : CFStreamClientContext?
    var writeStreamContext : CFStreamClientContext?
    var clientID = 0
    var clientStatus = ClientStatus.none{
        didSet{
            if clientStatus == ClientStatus.streamError{
                let delayInSeconds = 5.0
                let delay = Int64(delayInSeconds*Double(NSEC_PER_MSEC))
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay)
                dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.StreamError, object: nil)
                }
            }
        }
    }
    var messageHandler: XMessageHandler!
    var locationManager: XLocationManager!
}

class TCPClient{
    let serverIP = "115.159.38.35"
    let port = 6666
    let timeout = 5.0
    
    var clientContext = TCPClientContext()
    
    init(){
        clientContext.messageHandler = XMessageHandler(owner: self)
        
        //create Socketstream
        var inputStream: Unmanaged<CFReadStream>?
        var outputStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, serverIP, UInt32(port), &inputStream, &outputStream
        )
        clientContext.readStream = inputStream!.takeUnretainedValue()
        clientContext.writeStream = outputStream!.takeUnretainedValue()
        clientContext.readStreamContext = CFStreamClientContext(version: 0, info: &clientContext, retain: nil, release: nil, copyDescription: nil)
        CFReadStreamSetClient(
            clientContext.readStream,
            CFStreamEventType.HasBytesAvailable.rawValue | CFStreamEventType.ErrorOccurred.rawValue,
            ClientCallBackRead,
            &clientContext.readStreamContext!
        )
        
        let qos = Int(QOS_CLASS_UTILITY.rawValue)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue){
            CFReadStreamScheduleWithRunLoop(self.clientContext.readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
            CFRunLoopRun()
        }
        
    }
 
    func SendString(stringToSend: String){
        dispatch_async(clientContext.clientQ){
            let buf = NSMutableData(capacity: self.clientContext.bufferSize)
            let buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
            stringToSend.dataUsingEncoding(NSUTF8StringEncoding)!.getBytes(UnsafeMutablePointer<Void>(buffer), length: stringToSend.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            CFWriteStreamWrite(
                self.clientContext.writeStream,
                buffer,
                stringToSend.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            )
            print("Send: ", stringToSend)
        }
    }
    
    func ConnectAndInitialize(){
        if CFReadStreamOpen(clientContext.readStream) == false{
            clientContext.clientStatus = ClientStatus.streamError
            print("Cannot open stream\n")
        }
        if CFWriteStreamOpen(clientContext.writeStream) == false{
            clientContext.clientStatus = ClientStatus.streamError
            print("Cannot open stream\n")
        }
        if clientContext.clientStatus != ClientStatus.streamError{
            clientContext.clientStatus = ClientStatus.connected
        }
        clientContext.locationManager = XLocationManager(client: self)
    }
}

func ClientCallBackRead(stream: CFReadStream!, _ eventType: CFStreamEventType, _ clientCallBackInfo : UnsafeMutablePointer<Void>){
    let clientContextPointer = UnsafeMutablePointer<TCPClientContext>(clientCallBackInfo)
    let clientContext = clientContextPointer.memory
    if eventType == CFStreamEventType.ErrorOccurred{
        clientContext.clientStatus = ClientStatus.streamError
    }
    if eventType == CFStreamEventType.HasBytesAvailable{
        
        dispatch_async(clientContext.clientQ){
            let buffer = UnsafeMutablePointer<UInt8>.alloc(clientContext.bufferSize)
            let length = CFReadStreamRead(stream, buffer, clientContext.bufferSize)
            print(length)
            if length > 0{
                let str =  String.fromCString(UnsafePointer<CChar>(buffer))
                let message = XMessage(str!)!
                clientContext.messageHandler.PushMessage(message)
                print("Message received:", message.toJSON())
            }
        }
    }
}








