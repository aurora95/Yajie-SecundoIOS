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
    
    var readStream : CFReadStream?
    var writeStream: CFWriteStream?
    var readStreamContext : CFStreamClientContext?
    var writeStreamContext : CFStreamClientContext?
    var messageHandler: XMessageHandler!
    var clientID: Int?
    
    init(){
        messageHandler = XMessageHandler(owner: self)
        var inputStream: Unmanaged<CFReadStream>?
        var outputStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            serverIP,
            UInt32(port),
            &inputStream,
            &outputStream
        )
        readStream = inputStream!.takeUnretainedValue()
        writeStream = outputStream!.takeUnretainedValue()
        var client = self
        readStreamContext = CFStreamClientContext(version: 0, info:  &client, retain: nil, release: nil, copyDescription: nil)
        CFReadStreamSetClient(
            readStream,
            CFStreamEventType.HasBytesAvailable.rawValue & CFStreamEventType.ErrorOccurred.rawValue,
            ClientCallBackRead,
            &readStreamContext!
        )
        CFReadStreamScheduleWithRunLoop(
            readStream,
            CFRunLoopGetCurrent(),
            kCFRunLoopDefaultMode
        )
        if CFReadStreamOpen(readStream) == false{
            streamError = true
            print("Cannot open stream\n")
        }
        if CFWriteStreamOpen(writeStream) == false{
            streamError = true
            print("Cannot open stream\n")
        }
    }
 
    func SendString(stringToSend: String){
        dispatch_async(clientQ){
            let buf = NSMutableData(capacity: self.bufferSize)
            let buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
            stringToSend.dataUsingEncoding(NSUTF8StringEncoding)!.getBytes(UnsafeMutablePointer<Void>(buffer), length: stringToSend.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            CFWriteStreamWrite(
                self.writeStream,
                buffer,
                stringToSend.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            )
        }
    }
}

func ClientCallBackRead(stream: CFReadStream!, _ eventType: CFStreamEventType, _ clientCallBackInfo : UnsafeMutablePointer<Void>){
    let clientPointer = UnsafeMutablePointer<TCPClient>(clientCallBackInfo)
    let client = clientPointer.memory
    
    if eventType == CFStreamEventType.ErrorOccurred{
        client.streamError = true
    }
    if eventType == CFStreamEventType.HasBytesAvailable{
        
        dispatch_async(client.clientQ){
            let buf = NSMutableData(capacity: client.bufferSize)
            let buffer = UnsafeMutablePointer<UInt8>(buf!.bytes)
            let length = CFReadStreamRead(stream, buffer, client.bufferSize)
            if length > 0{
                let message = XMessage(String(buffer))!
                client.messageHandler.PushMessage(message)
            }
            
        }
    }
}








