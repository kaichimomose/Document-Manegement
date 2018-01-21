//
//  ViewController.swift
//  Document-Management
//
//  Created by Kaichi Momose on 2018/01/19.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import UIKit
import Zip

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var collections = [Collections]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableview.dataSource = self
        tableview.delegate = self
        
        tableview.register(UINib(nibName: "CollectionsCell", bundle: .main), forCellReuseIdentifier: "CollectionsCell")
        
        let path = Bundle.main.path(forResource: "collection-resource", ofType: ".json")
        if let path = path {
            let url = URL(fileURLWithPath: path)
            let content = try? Data(contentsOf: url, options: .alwaysMapped)
            let collections = try? JSONDecoder().decode([Collections].self, from: content!)
            guard let Collections = collections else {return}
            self.collections = Collections
            let fileManeger = FileManager.default
            let fileUrls = fileManeger.urls(for: .cachesDirectory, in: .userDomainMask)
            var index = 0
            for collection in self.collections {
                Downloader.load(url: collection.zippedImagesUrl, to: fileUrls[0], completion: {(filePath) in
                    self.collections[index].unzippedImagesUrl = filePath
                    index += 1
                })
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "CollectionsCell", for: indexPath) as! CollectionsCell
        let row = indexPath.row
        cell.collectionNameLabel.text = collections[row].collectionName
        print(collections[row].unzippedImagesUrl ?? "")
        return cell
    }
    
    
}


