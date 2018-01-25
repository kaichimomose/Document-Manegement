//
//  Networking.swift
//  Document-Management
//
//  Created by Kaichi Momose on 2018/01/22.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import Foundation

class Networking {
    let session = URLSession.shared
    let baseurl = "https://s3-us-west-2.amazonaws.com/mob3/image_collection.json"
    
    func fetch(complition: @escaping (Decodable)->()) {
        let url = URL(string: baseurl)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data, error == nil {
                do  {
                    let collections = try JSONDecoder().decode([Collections].self, from: data)
                    complition(collections)
                } catch(let err) {
                    print("File decoding: \(err)")
                }
            } else {
                print("Session Filure: \(String(describing: error))")
            }
        }.resume()
    }
}
