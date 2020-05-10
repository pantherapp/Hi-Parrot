//
//  FirebaseStorageManager.swift
//

import UIKit
import FirebaseStorage

class FirebaseStorageManager {
    
    public func uploadFile(localFile: URL, dir: String, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
//        let storage = Storage.storage()
        let storageRef = Storage.storage().reference()
        // Create a reference to the file you want to upload
        let directory = "\(dir)/"
        let fileRef = storageRef.child(directory + serverFileName)
        print("fileRef:", fileRef.debugDescription)

        _ = fileRef.putFile(from: localFile, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func uploadImageData(data: Data, dir: String, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "\(dir)/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }

}
