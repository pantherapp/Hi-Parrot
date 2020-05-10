

import Foundation
import Firebase
import SwiftyJSON
import CoreLocation
import GeoFire
import FirebaseFirestore


var localURL = String()

class FirebaseAPI {
    
    //MARK:-    set variable data
    static let serverURL                = "https://parrot-c87c3.firebaseio.com/"
    static let db                       = Firestore.firestore()
    static let voiceCollection          = db.collection("voices")
    static let notificationCollection   = db.collection("notifications")
    static let storageRef               = Storage.storage()
    
    
    //MARK:-    parse Voice data
    static func parseVoiceData(_ document: QueryDocumentSnapshot) -> VoiceModel {
        
        let data        =  document.data()
        let doc_rowid   = document.documentID
        
        let user_udid           = data[USER_UDID] as? String ?? ""
        let user_device_name    = data[USER_DEVICE_NAME] as? String ?? ""
        let user_system_name    = data[USER_SYSTEM_NAME] as? String ?? ""
        let user_system_version = data[USER_SYSTEM_VERSION] as? String ?? ""
        let user_token          = data[USER_TOKEN] as? String ?? ""
        let timeTemp            = data[CREATED_TIMESTAMP] as? Int64 ?? Int64(NSDate().timeIntervalSince1970)
        let created_date        = "\(timeTemp)"
        let voice_url           = data[VOICE_URL] as? String ?? ""
        let comment_count       = data[COMMENT_COUNT] as? Int ?? 0
        let comment_users       = data[COMMENT_USERS] as? [String] ?? [String]()
        let like_users          = data[LIKE_USERS] as? [String] ?? [String]()
        let report_users        = data[REPORT_USERS] as? [String] ?? [String]()
        let user_address        = data[ADDRESS] as? String ?? ""
//        let user_location       = data[USER_LOCATION] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
//        let like_count          = like_users.count
//        let is_like             = like_users.contains(myUDID)
        
        let one = VoiceModel(
                doc_rowid: doc_rowid, user_udid: user_udid, user_device_name: user_device_name, user_system_name: user_system_name,
                user_system_version: user_system_version, user_token: user_token, created_date: created_date, voice_url: voice_url,
                comment_users: comment_users, like_users: like_users, report_users: report_users, user_address: user_address
        )
        
        return one
    }
    

    //MARK:-----    download file as local temp
    static func downloadFile (voice_url : String, timeStr : String) {

        let httpsRef = storageRef.reference(forURL: voice_url)

        let fileUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let pathString = "\(timeStr).m4a"
        
        localURL = fileUrls.first!.absoluteString
        guard let fileUrl = fileUrls.first?.appendingPathComponent(pathString) else {
            return
        }
        
        if FileManager().fileExists(atPath: fileUrl.path) {}
        else {
            let downloadTask = httpsRef.write(toFile: fileUrl)
            downloadTask.observe(.success) { _ in
                do {
                    print("download observe localURL ==>", "\(localURL)")
                } catch let error {
                    print("download Error ==>", "\(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK:- save recorded My Voice
    static func saveMyRecordVoice(_ data:[String:Any], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        var ref: DocumentReference? = nil
        ref = voiceCollection.addDocument(data: data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                completion(true, ref!.documentID)
            }
        }
    }
    
    
    static func getMyRecordVoice(completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
        
        voiceCollection.whereField(USER_UDID, isEqualTo: myUDID)
            .order(by: CREATED_TIMESTAMP, descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err)
            } else {
                
                var result = [VoiceModel]()
                
                guard let snap = querySnapshot else { return }
                for document in snap.documents {
                    
                    let one = parseVoiceData(document)
                    downloadFile(voice_url: one.voice_url, timeStr: one.created_date)

                    result.append(one)
                }
                
                completion(true, result)
            }
        }
    }
 
    
    static func addListenerMyRecordVoice(completion: @escaping (_ state: Bool, _ result: Any, _ changedType: DocumentChangeType) -> () ) {
        
        voiceCollection.whereField(USER_UDID, isEqualTo: myUDID).addSnapshotListener { querySnapshot, error in
            
            var changedType = DocumentChangeType.added
            var result = [VoiceModel]()
            
            if let err = error {
                completion(false, err, changedType)
            }
            else {
                guard let snapshot = querySnapshot else {return}
                
//                let source = snapshot.metadata.hasPendingWrites ? "Local" : "Server"
                snapshot.documentChanges.forEach { diff in
                    
                    changedType = diff.type
                    
                    let one = parseVoiceData(diff.document)
                    downloadFile(voice_url: one.voice_url, timeStr: one.created_date)
                    result.append(one)
                }
                
                completion(true, result, changedType)
            }
        }
    }
    
    static func deleteMyOneRecordVoice(_ voice_url: String, _ doc_rowid: String, completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        
        // Create a reference to the file to delete
        let desertRef = storageRef.reference(forURL: voice_url)

        // Delete the file
        desertRef.delete { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                print("Remote File deleted successfully")
            }
        }
          
        
        voiceCollection.document("\(doc_rowid)").delete() { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Document successfully removed!")
            }
        }
        
//        voiceCollection.whereField("id", isEqualTo: doc_rowid).getDocuments {(querySnapshot, error) in
//            if error != nil {
//                print(error)
//            } else {
//                for document in querySnapshot!.documents {
//                    document.reference.delete()
//                }
//            }
//        }
    }
    
    
    // MARK:- get near Voice from current user
    static func getNearbyVoice(myLocation: CLLocationCoordinate2D, distance: Double, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
        
        let latitude = myLocation.latitude
        let longitude = myLocation.longitude
        
        let myGeopoint = GeoPoint(latitude: latitude, longitude: longitude)
        let r_earth : Double = 6378137  // Radius of earth in Meters

        // 1 degree lat in m
        let kLat = (2 * Double.pi / 360) * r_earth
        let kLon = (2 * Double.pi / 360) * r_earth * __cospi(latitude/180.0)

        let deltaLat = distance / kLat
        let deltaLon = distance / kLon

        let swGeopoint = GeoPoint(latitude: latitude - deltaLat, longitude: longitude - deltaLon)
        let neGeopoint = GeoPoint(latitude: latitude + deltaLat, longitude: longitude + deltaLon)

        
        let query = voiceCollection.whereField(USER_LOCATION, isGreaterThan: swGeopoint)
                        .whereField(USER_LOCATION, isLessThan: neGeopoint)
        
        query//.order(by: CREATED_TIMESTAMP, descending: true)
            .getDocuments { snapshot, error in
            if let error = error {
                completion(false, error)
            }
            else {
                
                var result = [VoiceModel]()
                
                for document in snapshot!.documents {
                    
                    let one = parseVoiceData(document)
                    
                    if let location = document.get(USER_LOCATION) as? GeoPoint {
                        let myDistance = distanceBetween(geoPoint1:myGeopoint, geoPoint2:location)
                        print("myDistance:\(myDistance) distance:\(distance)")
                    }
                    
                    downloadFile(voice_url: one.voice_url, timeStr: one.created_date)
                    result.append(one)
                }
                completion(true, result)
            }
        }
    }
    
    static func addListenerNearVoice(myLocation: CLLocationCoordinate2D, distance: Double, completion: @escaping (_ state: Bool, _ result: Any, _ changedType: DocumentChangeType) -> () ) {
        let latitude = myLocation.latitude
        let longitude = myLocation.longitude
        
        let myGeopoint = GeoPoint(latitude: latitude, longitude: longitude)
        let r_earth : Double = 6378137  // Radius of earth in Meters

        // 1 degree lat in m
        let kLat = (2 * Double.pi / 360) * r_earth
        let kLon = (2 * Double.pi / 360) * r_earth * __cospi(latitude/180.0)

        let deltaLat = distance / kLat
        let deltaLon = distance / kLon

        let swGeopoint = GeoPoint(latitude: latitude - deltaLat, longitude: longitude - deltaLon)
        let neGeopoint = GeoPoint(latitude: latitude + deltaLat, longitude: longitude + deltaLon)

        let query = voiceCollection.whereField(USER_LOCATION, isGreaterThan: swGeopoint)
                        .whereField(USER_LOCATION, isLessThan: neGeopoint)
        
        
        query//.order(by: CREATED_TIMESTAMP, descending: true)
            .addSnapshotListener { querySnapshot, error in
                
                var changedType = DocumentChangeType.added
                var result = [VoiceModel]()
                
                if let err = error {
                    completion(false, err, changedType)
                }
                else {
                    guard let snapshot = querySnapshot else {return}
                    
                    for diff in snapshot.documentChanges {
                        changedType = diff.type
                        
                        let one = parseVoiceData(diff.document)
                        
                        downloadFile(voice_url: one.voice_url, timeStr: one.created_date)
                        
                        result.append(one)
                    }
                    
                    completion(true, result, changedType)
                }
            }
        }
        
    static func reportNearVoice(_ doc_id: String, _ value: [String], completion: @escaping (_ state: Bool) -> () ) {

        voiceCollection.document(doc_id).updateData([REPORT_USERS: value]){ err in
            if let err = err {
                print("report_update_fail", err.localizedDescription)
                completion(false)
            } else {
                print("report_update_success")
                completion(true)
            }
        }
    }
    
    static func setLikeNearVoice(_ doc_id: String, _ value: [String], completion: @escaping (_ state: Bool) -> () ) {

        voiceCollection.document(doc_id).updateData([LIKE_USERS: value]){ err in
            if let err = err {
                print("like_update_fail", err.localizedDescription)
                completion(false)
            } else {
                print("like_update_success")
                completion(true)
            }
        }
    }
    
    
    // MARK:- save comment for Voice
    static func saveCommentVoice(_ doc_id: String, _ data:[String:Any], completion: @escaping (_ status: Bool, _ result: String) -> ()) {
        var ref: DocumentReference? = nil
        ref = voiceCollection.document(doc_id).collection("comments").addDocument(data: data) { err in
            if let err = err {
                completion(false, err.localizedDescription)
            } else {
                
                let voice_update_data = [
                        COMMENT_COUNT: data[COMMENT_COUNT] as! Int,
                        COMMENT_USERS: data[COMMENT_USERS] as! [String]
                    ] as [String : Any]
                
                voiceCollection.document(doc_id).updateData(voice_update_data)
                completion(true, ref!.documentID)
            }
        }
    }
    
    static func getCommentVoice(_ user_udid: String, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
            
        voiceCollection.document(user_udid).collection("comments")
            .order(by: CREATED_TIMESTAMP, descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err)
                
            } else {
                var result = [VoiceModel]()
                guard let snap = querySnapshot else { return }
                for document in snap.documents {
                    let one = parseVoiceData(document)
                    downloadFile(voice_url: one.voice_url, timeStr: one.created_date)
                    result.append(one)
                }
                
                completion(true, result)
            }
        }
    }

    static func addListenerCommentVoice(_ doc_id: String, completion: @escaping (_ state: Bool, _ result: Any, _ changedType: DocumentChangeType) -> () ) {
        
        voiceCollection.document(doc_id).collection("comments")
            
            .addSnapshotListener { querySnapshot, error in
                
                var changedType = DocumentChangeType.added
                var result = [VoiceModel]()
                
                if let err = error {
                    completion(false, err, changedType)
                }
                else {
                    guard let snapshot = querySnapshot else {return}
                    
                    
                    for diff in snapshot.documentChanges {
                        
                        changedType = diff.type
                        
                        let one = parseVoiceData(diff.document)
                        
                        if one.user_udid == "" { continue }
//                        if one.user_udid == myUDID { continue }
                        
                        downloadFile(voice_url: one.voice_url, timeStr: one.created_date)
                        
                        result.append(one)
                    }
                    
                    completion(true, result, changedType)
                }
            }
    }
    
    static func reportCommentVoice(_ voice_docId: String, _ comment_docId: String, _ value: [String], completion: @escaping (_ state: Bool) -> () ) {

        voiceCollection.document(voice_docId).collection("comments").document(comment_docId).updateData([REPORT_USERS: value]){ err in
            if let err = err {
                print("report_update_fail", err.localizedDescription)
                completion(false)
            } else {
                print("report_update_success")
                completion(true)
            }
        }
    }
    
    static func setLikeCommentVoice(_ voice_docId: String, _ comment_docId: String, _ value: [String], completion: @escaping (_ state: Bool) -> () ) {

        voiceCollection.document(voice_docId).collection("comments").document(comment_docId).updateData([LIKE_USERS: value]){ err in
            if let err = err {
                print("like_update_fail", err.localizedDescription)
                completion(false)
            } else {
                print("like_update_success")
                completion(true)
            }
        }
    }
    
    //MARK:- Mentions
    static func getMentionData(completion: @escaping (_ state: Bool, _ result: Any) -> ()) {
        
        notificationCollection.whereField(USER_UDID, isEqualTo: myUDID).getDocuments() { (querySnapshot, err) in
            
            if err != nil {
                completion(false, err!.localizedDescription)
            } else {
                
                guard let snap = querySnapshot else {
                    completion(false, "No data")
                    return
                }
                for document in snap.documents {
                    let noti_docId = document.documentID
                    print("MentionData===>noti_doc_id=====>", noti_docId)
                    
                    notificationCollection.document(noti_docId).collection(MENTIONS).getDocuments() { (mentionSnapshot, err) in

                        if let err = err {
                            completion(false, err.localizedDescription)
                            
                        }
                        else {
                            var result = [MentionModel]()
                            guard let snap = mentionSnapshot else { return }
                            
                            for document in snap.documents {
                                let mention_docid = document.documentID
                                print("MentionData===>noti_doc_id=====>\(noti_docId), mention_doc_id=====>", mention_docid)
                                let data = document.data()
                                
                                let timestamp       = data[CREATED_TIMESTAMP] as? Int64 ?? Int64(NSDate().timeIntervalSince1970)
                                let comment_docid   = data[COMMENTTED_DOCID] as? String ?? ""
                                
                                let one = MentionModel(noti_docId: noti_docId, mention_docid: mention_docid, created_date: "\(timestamp)", comment_docid: comment_docid)

                                result.append(one)
                            }
                            completion(true, result)
                        }
                    }
                }
                completion(false, "No data")
            }
        }
    }
    
    static func addListenerMentions(completion: @escaping (_ state: Bool, _ result: Any, _ changedType: DocumentChangeType) -> () ) {
        
        notificationCollection.whereField(USER_UDID, isEqualTo: myUDID)
            //.order(by: CREATED_TIMESTAMP, descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                completion(false, err.localizedDescription, DocumentChangeType.added)
                
            } else {
                guard let snap = querySnapshot else { return }
                for document in snap.documents {
                    let noti_docId = document.documentID
                    
                    notificationCollection.document(noti_docId).collection(MENTIONS).addSnapshotListener { querySnapshot, error in
                        
                        var changedType = DocumentChangeType.added
                        var result = [MentionModel]()
                        
                        if let err = error {
                            completion(false, err.localizedDescription, changedType)
                        }
                        else {
                            guard let snapshot = querySnapshot else {return}
                            
                            for diff in snapshot.documentChanges {
                                changedType = diff.type
                                
                                let document = diff.document
                                let doc_id = document.documentID
                                let data = document.data()
                                let timestamp       = data[CREATED_TIMESTAMP] as? Int64 ?? Int64(NSDate().timeIntervalSince1970)
                                let comment_docid   = data[COMMENTTED_DOCID] as? String ?? ""
                                
                                let one = MentionModel(noti_docId: noti_docId, mention_docid: doc_id, created_date: "\(timestamp)", comment_docid: comment_docid)
                                result.append(one)
                            }
                            
                            completion(true, result, changedType)
                        }
                    }
                }
            }
        }
    }
    
    static func deleteMentionData(_ noti_docId: String, _ mention_docId: String, completion: @escaping (_ state: Bool, _ result: Any) -> () ) {
        notificationCollection.document(noti_docId).collection(MENTIONS).document("\(mention_docId)").delete() { error in
            if let err = error {
                completion(false, err.localizedDescription)
            } else {
                
                let badgeCount = UIApplication.shared.applicationIconBadgeNumber - 1
                
                notificationCollection.document(noti_docId).updateData([BADGE_COUNT: badgeCount]){ err in
                    if let err = err {
                        print("update_badgeCount_fail", err.localizedDescription)
                        completion(false, err.localizedDescription)
                    } else {
                        completion(true, badgeCount)
                    }
                }
            }
        }
    }
    
    // MARK:-  setEnableNotification
    static func setEnableNotification(_ state: Bool, completion: @escaping (_ state: Bool) -> () ) {
        
        notificationCollection.whereField(USER_UDID, isEqualTo: myUDID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("noti_get_fail", err.localizedDescription)
                completion(false)
                
            } else {
                
                if let snap = querySnapshot {
                    if snap.documents.count > 0 {
                        for document in snap.documents {
                            let doc_id = document.documentID
                            
                            notificationCollection.document(doc_id).updateData([ENABLE_NOTI: state, USER_TOKEN: deviceTokenString]){ err in
                                if let err = err {
                                    print("noti_update_fail", err.localizedDescription)
                                    completion(false)
                                } else {
                                    print("noti_update_success")
                                    completion(true)
                                }
                            }
                        }
                    }
                    else {
                        let data = [
                                USER_UDID           : myUDID,
                                ENABLE_NOTI         : state,
                                BADGE_COUNT         : 0,
                                USER_TOKEN          : deviceTokenString,
                            ] as [String : Any]
                            
                        notificationCollection.addDocument(data: data) { err in
                            if let err = err {
                                print("noti_create_fail", err.localizedDescription)
                                completion(false)
                            } else {
                                print("noti_create_success")
                                completion(true)
                            }
                        }
                    }
                }
                else {
                    completion(false)
                }
            }
        }
    }

    static func checkAndSaveMention(_ user_udid: String, _ comment_docId: String, completion: @escaping (_ result: Bool, _ status: Any, _ user_token: String, _ badgeCount: Int) -> ()){
        notificationCollection.whereField(USER_UDID, isEqualTo: user_udid)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("noti_get_fail", err.localizedDescription)
                completion(false, err.localizedDescription, "", 0)
                
            } else {
                if let snap = querySnapshot {
                    if snap.documents.count > 0 {
                        var enableNoti = false
                        var badgeCount = 0
                        var user_token = ""
                        for document in snap.documents {
                            let data = document.data()
                            enableNoti = data[ENABLE_NOTI] as? Bool ?? false
                            user_token = data[USER_TOKEN] as? String ?? ""
                            badgeCount = data[BADGE_COUNT] as? Int ?? 0
                            
                            if enableNoti == true {
                                
                                let data = [
                                    CREATED_TIMESTAMP   : Int64(NSDate().timeIntervalSince1970),
                                    COMMENTTED_DOCID    : comment_docId,
                                ] as [String : Any]
                                
                                badgeCount += 1
                                
                                var ref: DocumentReference? = nil
                                ref = notificationCollection.document(document.documentID).collection(MENTIONS).addDocument(data: data) { err in
                                    if let err = err {
                                        print("fail_save_mention_data", err.localizedDescription)
                                        completion(false, enableNoti, user_token, badgeCount)
                                    } else {
                                        print("save_mention_data", ref?.documentID)
                                        
                                        notificationCollection.document(document.documentID).updateData([BADGE_COUNT: badgeCount]){ err in
                                            if let err = err {
                                                print("save_mention_badge_fail", err.localizedDescription)
                                            } else {
                                                print("save_mention_badge_success")
                                            }
                                        }
                                        completion(true, enableNoti, user_token, badgeCount)
                                    }
                                }
                            }
                        }
                    }
                }
                
                completion(true, false, NON_REGISTER_NOTI_SETTING, 0)
            }
        }
    }
}

    
//MARK:-    get distance Between two GeoPoint
func distanceBetween(geoPoint1: GeoPoint, geoPoint2:GeoPoint) -> Double {
    return distanceBetween(lat1: geoPoint1.latitude,
                           lon1: geoPoint1.longitude,
                           lat2: geoPoint2.latitude,
                           lon2: geoPoint2.longitude)
}

func distanceBetween(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double{  // generally used geo measurement function
    let R : Double = 6378.137; // Radius of earth in KM
    
    let dLat = (lat2 - lat1) * Double.pi / 180; // let dLat = lat2 * Double.pi / 180 - lat1 * Double.pi / 180;
    let dLon = (lon2 - lon1) * Double.pi / 180; // let dLon = lon2 * Double.pi / 180 - lon1 * Double.pi / 180;
    
    
    let a = sin(dLat/2) * sin(dLat/2) +
        cos(lat1 * Double.pi / 180) * cos(lat2 * Double.pi / 180) *
        sin(dLon/2) * sin(dLon/2);
    let c = 2 * atan2(sqrt(a), sqrt(1-a));
    let d = R * c;
    return d * 1000; // meters
}
