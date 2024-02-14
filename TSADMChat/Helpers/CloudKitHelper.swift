//
//  CloudKitHelper.swift
//  TSADMChat
//
//  Created by Gabriel Marro on 22/11/23.
//

import Foundation
import CloudKit
import UIKit

/**
 # CloudKitHelper #
 A struct to manage the CloudKit operations. It contains the functions to download the messages and to send a message.
 */
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
    
    public func downloadMessages(from: Date?) async -> ([CKMessage],[User]) {
        var messages = [CKMessage]()
        var users: [User] = []
        
        await downloadMessages(from: from) { recordID, recordResult in
            
            switch (recordResult) {
            case .success(let record):
                let user = record.creatorUserRecordID?.recordName
                let date = record.creationDate!
                let text = record["text"] as! String? ?? ""
                
                var image: Data? = nil
                if record["image"] != nil{
                    image = (record["image"] as! CKAsset).toData()
                }
                messages.append(
                    CKMessage(id:recordID.recordName,date:date,userID: user,text:text,image:image)
                )
                
            case .failure(let error):
                print("Error retrieving data: \(error)")
            }
        }
        
        for message in messages {
            do{
                let idUser = message.userID!
                if try users.filter(#Predicate{ user in user.id == idUser}).isEmpty{
                    let result = await getUser(recordID: idUser)
                    switch (result) {
                    case .success(let newUser):
                        users.append(newUser)
                        
                        
                    case .failure(let error):
                        print("Error retrieving data: \(error)")
                        
                    }
                }
            }catch{
                print(error)
            }
        }
        
        return (messages,users)
    }
    
    
    public func updateUser(newName: String, image: CKAsset?) async throws -> Result<Void, Error> {
        let recordID = try await myUserRecordID()
        let container = CKContainer.default()
        let db = container.publicCloudDatabase
        
        do {
            let record = try await db.record(for: CKRecord.ID(recordName: recordID))
            print(record)
            record["name"] = newName  // Assign the new name directly
            if image != nil{
                record["thumbnail"] = image
            }
            try await db.save(record)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    public func getUser(recordID: String) async -> Result<User, Error> {
        let container = CKContainer.default()
        let db = container.publicCloudDatabase
        do {
            let record = try await db.record(for: CKRecord.ID(recordName: recordID))
            let name = record["name"] as! String? ?? ""
            var image: Data? = nil
            if record["thumbnail"] != nil{
                image = (record["thumbnail"] as! CKAsset).toData()
            }
            let user = User(id: record.creatorUserRecordID?.recordName, name: name, image: image)
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
    
    public func sendMessage(_ text: String, _ attachment: Data?) async throws -> CKRecord {
        let message = CKRecord(recordType: "Message")
        message["text"] = text as NSString
        if (attachment != nil) {
            message["image"] = attachment?.toCKAsset()
        }
        let db = CKContainer.default().publicCloudDatabase
        //TODO: Return for the record id
        return try await db.save(message)
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
