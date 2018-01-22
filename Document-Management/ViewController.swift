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
    
//    var cell = CollectionsCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableview.dataSource = self
        tableview.delegate = self
        
//        cell = tableview.dequeueReusableCell(withIdentifier: "CollectionsCell") as! CollectionsCell
        
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
                    DispatchQueue.main.async {
                        let filename = ["forest", "lion", "swimming", "heath & food"]
                        self.collections[index].unzippedImagesUrl = filePath.appendingPathComponent(filename[index])
                        index += 1
                        self.tableview.reloadData()
                    }
                })
            }
        }
    }
    
    private func loadImage(fileURL: URL?) -> UIImage? {
        do {
            guard let fileURL = fileURL else {return nil}
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "CollectionsCell", for: indexPath) as! CollectionsCell
        let row = indexPath.row
        //set
        cell.progressIndicator.hidesWhenStopped = true
        
        cell.collectionNameLabel.text = collections[row].collectionName
        
//        func contentsOfDirectoryAtPath(path: String) -> [String]? {
//            guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
//            return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
//        }
//
//        let searchPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
//
//        print(searchPath)
        
//        let allContents = contentsOfDirectoryAtPath(path: searchPath + "/lion")
//        print(allContents)

        cell.thumbnailImage.image = loadImage(fileURL: collections[row].unzippedImagesUrl?.appendingPathComponent("_preview.png"))
        if cell.thumbnailImage.image != nil {
            cell.progressIndicator.stopAnimating()
        } else {
            cell.progressIndicator.startAnimating()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let unzippedImageUrl = collections[row].unzippedImagesUrl
        
//        do {
//            if let url = unzippedImageUrl {
//                let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
//                let jpegFiles = directoryContents.filter{ $0.pathExtension == "jpeg" }
//                print("jpeg urls:",jpegFiles)
//            }
//        } catch {
//            print("\(error)")
//        }
        
        let imageCVC = storyboard?.instantiateViewController(withIdentifier: "ImageCollectionViewController") as! ImageCollectionViewController
        imageCVC.unzippedImageUrl = unzippedImageUrl
        navigationController?.pushViewController(imageCVC, animated: true)
    }
    
}


