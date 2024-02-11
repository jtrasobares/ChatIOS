//
//  CloudKitHelper.swift
//  TSADMChat
//
//  Created by Gabriel Marro on 22/11/23.
//

import Foundation
import CloudKit
import UIKit

struct CloudKitHelper {
    
    static let subscriptionID = "NEW_MESSAGE"
    
    public func myUserRecordID() async throws -> String {
        let container = CKContainer.default()
        let record = try await container.userRecordID()
        return record.recordName
    }
    
    public func downloadMessages(from: Date?,perRecord: @escaping (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void) async -> Error? {
        
        await withCheckedContinuation { continuation in
            let container = CKContainer.default()
            let db = container.publicCloudDatabase
            let predicate: NSPredicate
            if let date = from {
                predicate = NSPredicate(format: "creationDate > %@", date as NSDate)
            } else {
                predicate = NSPredicate(value: true)
            }
            
            let query = CKQuery(recordType: "Message", predicate: predicate)
            query.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true)]
            
            func completion(_ operationResult: Result<CKQueryOperation.Cursor?, Error>) {
                switch operationResult {
                case .success(let cursor):
                    if let cursor = cursor {
                        let newOp = CKQueryOperation(cursor: cursor)
                        newOp.recordMatchedBlock = perRecord
                        newOp.queryResultBlock = completion
                        db.add(newOp)
                    } else {
                        continuation.resume(returning: nil)
                    }
                    break
                case .failure(let error):
                    continuation.resume(returning: error)
                    break
                }
            }
            
            let queryOp = CKQueryOperation(query: query)
            //queryOp.recordFetchedBlock = perRecord
            queryOp.recordMatchedBlock = perRecord
            queryOp.queryResultBlock = completion
            db.add(queryOp)
        }
    }
    
    /*public func downloadMessages(from: Date?) async -> [Message] {
           var messages = [Message]()
           
           await downloadMessages(from: from) { recordID, recordResult in
               switch (recordResult) {
               case .success(let record):
                   let user = record.creatorUserRecordID?.recordName
                   if let text = record["text"] as? String{
                       messages.append(
                        Message(id:recordID.recordName,user: user,text:text)
                       )
                   }
               case .failure(let error):
                   print("Error retrieving data: \(error)")
               }
           }
           
           return messages
       }*/
    
    
    public func sendMessage(_ text: String) async throws {
        let message = CKRecord(recordType: "Message")
        message["text"] = text as NSString
        let db = CKContainer.default().publicCloudDatabase
        try await db.save(message)
    }
    
    public func checkForSubscriptions() async throws -> CKSubscription? {
        let db = CKContainer.default().publicCloudDatabase
        let subscriptions = try await db.allSubscriptions()
        if !subscriptions.contains(where: { subscription in
            subscription.subscriptionID == CloudKitHelper.subscriptionID
        }) {
            let options:CKQuerySubscription.Options
            options = [.firesOnRecordCreation]
            let predicate = NSPredicate(value: true)
            let subscription = CKQuerySubscription(recordType: "Message",
                                                   predicate: predicate,
                                                   subscriptionID: CloudKitHelper.subscriptionID,
                                                   options: options)
            let info = CKSubscription.NotificationInfo()
            info.soundName = "chan.aiff"
            //info.alertBody = "New message"

            info.alertLocalizationKey = "%1$@"
            info.alertLocalizationArgs = ["text"]
            
            info.shouldSendMutableContent = true
            subscription.notificationInfo = info
            
            return try await db.save(subscription)
        }
        return nil
    }
    
    public func requestNotificationPermissions() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error{
                print(error)
            }else if success{
                print("Notification permissions success!")
                Task{
                   await UIApplication.shared.registerForRemoteNotifications()
                }
            }else{
                print("Notification permissions failure")
            }
        }
        
    }
        
    
    
}
