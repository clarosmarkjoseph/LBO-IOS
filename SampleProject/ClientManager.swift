//
//  ClientManager.swift
//  SampleProject
//
//  Created by OrangeApps Inc. on 8/10/17.
//  Copyright © 2017 itadmin. All rights reserved.
//


class ClientManager {
    
    static let sharedClient = MSClient(applicationURLString: "Endpoint=sb://laybarenamespace.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=wzShMuMA31Vfz48q7A1VHZDBhcK/WHA8qFoL0SUDgFY=")
}
