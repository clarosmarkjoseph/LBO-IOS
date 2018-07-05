//
//  ClientManager.swift
//  SampleProject
//
//  Created by OrangeApps Inc. on 8/10/17.
//  Copyright © 2017 itadmin. All rights reserved.
//


class ClientManager {
    static let sharedClient = MSClient(applicationURLString: "Endpoint=sb://laybare-hub.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=57n5ywFMdjQUpZj1sFuL2zBqU0JOoXtCkfpKDjnHsiY=")
}
