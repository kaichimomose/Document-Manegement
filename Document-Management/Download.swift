//
//  Download.swift
//  Document-Management
//
//  Created by Kaichi Momose on 2018/01/20.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import Foundation
import Zip

class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping (URL) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    Zip.addCustomFileExtension("tmp")
                    try Zip.unzipFile(tempLocalUrl, destination: localUrl, overwrite: true, password: nil, progress: { (progress) -> () in
                        print(progress)
                    }) // Unzip
//                    let unzipDirectory = try Zip.quickUnzipFile(tempLocalUrl)
                    
//                    try FileManager.default.copyItem(at: unzipDirectory, to: localUrl.appendingPathComponent(unzipDirectory.lastPathComponent))
                    completion(localUrl)
                } catch (let writeError){
                    print("Error wirting file \(localUrl): \(writeError)")
                }
            } else {
                print("Failure %@", error?.localizedDescription ?? "")
            }
        }
        task.resume()
    }
}
