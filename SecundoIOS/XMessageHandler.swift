//
//  XMessageHandler.swift
//  SecundoIOS
//
//  Created by YajieXing on 15/10/9.
//  Copyright © 2015年 Yajie Xing. All rights reserved.
//

import Foundation

class XMessageHandler
{
    weak var tcpClient: TCPClient?
    var messageQ = [XMessage]()
    init(owner: TCPClient){
        tcpClient = owner
        let qos = Int(QOS_CLASS_UTILITY.rawValue)
        let queue = dispatch_get_global_queue(qos, 0)
        dispatch_async(queue){
            self.MainWork()
        }
    }
    
    func PushMessage(message: XMessage){
        messageQ.append(message)
    }
    
    func MainWork(){
        while(true){
            if !messageQ.isEmpty{
                let message = messageQ.removeFirst()
                HandleMessage(message)
            }
        }
    }
    
    func HandleMessage(message:XMessage){
        
    }
}