//
//  PushNotificationSender.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, badgeCount: Int = 0) {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        var notificationContent: [String : Any] = [
            "title"     : title,
            "body"      : body,
            "priority"  : "high",
            "sound"     : "default",
            "content_available" : true
        ]
        if badgeCount > 0 {
            notificationContent["badge"] = badgeCount
        }
        
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : notificationContent,
                                           "data" : ["user" : "test_id"],
                                        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAbZR5u54:APA91bFksggKotkypAGGbRbrSKndA8bnaezGVF6Pkzhy6eTonT7uVLNMQI_d4fV8PKGGW5ocbgqGJPF3ewcvuQm4O5O6vJAR4XwAvj2y_JKBBEakehcrJ09AbhbGd7g3E6TepGWBoUVb", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
