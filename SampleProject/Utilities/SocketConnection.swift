//
//  SocketConnection.swift
//  SampleProject
//
//  Created by Paolo Hilario on 7/19/18.
//  Copyright © 2018 itadmin. All rights reserved.
//

import Foundation
import SocketIO


class SocketConnection{
    let utilities = Utilities()
    var socket:SocketIOClient!
    var socketManager:SocketManager!

    public init(){
        SocketConnection()
    }
    
    func SocketConnection(){
        print("Configuring web sockets")
        let socketURL   = URL(string: "https://socket.lay-bare.com")!
//        .forceWebsockets(true),
        socketManager   = SocketManager(socketURL: socketURL, config: [.log(false), .compress, .reconnects(true)])
        socket          = socketManager.defaultSocket
      
        socket.on(clientEvent: .connect) {data, ack in
//            print(data)
            print("socket connected: \(data)")
        }
        
        socket.on(clientEvent: .error) { (data, eck) in
//            print(data)
            print("socket error:  \(data)")
        }
        
        socket.on(clientEvent: .disconnect) { (data, eck) in
//            print(data)
            print("socket disconnect:  \(data)")
        }
        
        socket.on(clientEvent: SocketClientEvent.reconnect) { (data, eck) in
//            print(data)
            print("socket reconnect:  \(data)")
        }
        
    }
    
    func getWebSocket() -> SocketIOClient{
        return socket
    }
    
    
    
    
}
