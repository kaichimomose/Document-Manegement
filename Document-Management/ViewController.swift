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
        
        
        //tableview setup
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "CollectionsCell", bundle: .main), forCellReuseIdentifier: "CollectionsCell")
        
        
        //gets collections models from json file
        let path = Bundle.main.path(forResource: "collection-resource", ofType: ".json")
        let collections = decoding(path: path)
        guard let listOfCollections = collections else {return}
        self.collections = listOfCollections
        
        
        //file maneger setting
        let fileManeger = FileManager.default
        
        //file url to save unzipped file
        let fileUrl = try! fileManeger.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        
        //index of list of collections
        var index = 0
        
        //loop through list of collections
        for collection in self.collections {
            
            //downloads zipped file from an image url and save unzipped file to file url
            Downloader.load(from: collection.zippedImagesUrl, to: fileUrl, completion: {(result) in
                switch result {
                    
                    //when result is filepath of unzipped file
                    case let .done(filePath):
                        DispatchQueue.main.async {
                            
                            //gets an unzipped file name from a zipped image url
                            let filename = self.collections[index].zippedImagesUrl.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "+", with: " ")
                            
                            //saves an unzipped image url
                            self.collections[index].unzippedImagesUrl = filePath.appendingPathComponent(filename)
                            
                            //incriment number of index
                            index += 1
                            
                            //updates tableview cells
                            self.tableview.reloadData()
                        }
                    
                    //when result is unzipping progress...
                    case let .unzipping(progress):
                        
                        //update progress
                        self.collections[index].unzippingProgress = progress
                    
                    case let .downloading(progress):
                        print(progress)
                    
                    case let .error(error):
                        print(error)
                }
            })
        
        }
    }
    
    //decode json and return a list of collections models or nil
    private func decoding(path: String?) -> [Collections]? {
        do {
            guard let path = path else {return nil}
            
            //converts string to url
            let url = URL(fileURLWithPath: path)
            
            //gets json form the url
            let content = try Data(contentsOf: url, options: .alwaysMapped)
            
            //decodes json to collections models
            let collections = try JSONDecoder().decode([Collections].self, from: content)
            
            return collections
        } catch {
            print("Error decoding : \(error)")
        }
        return nil
    }
    
    //load image data from a url
    private func loadImage(fileURL: URL?) -> UIImage? {
        do {
            guard let fileURL = fileURL else {return nil}
            
            //gets data from the url
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
        
        cell.collectionNameLabel.text = collections[row].collectionName
        
        //load image from a file url
        cell.thumbnailImage.image = loadImage(fileURL: collections[row].unzippedImagesUrl?.appendingPathComponent("_preview.png"))
        
        //let progress indicator hide when its animation stop
        cell.progressIndicator.hidesWhenStopped = true
        
        if cell.thumbnailImage.image != nil {
            
            //stops animation when image exists
            cell.progressIndicator.stopAnimating()
        } else {
            
            //starts animaiton when image does not exist
            cell.progressIndicator.startAnimating()
        }
        
        if let unzippingProgress = collections[row].unzippingProgress {
            
            //
            cell.unzippingProgressView.progress = Float(unzippingProgress)
            if cell.unzippingProgressView.progress == 1.0{
                cell.unzippingProgressView.isHidden = true
            }
        }
        
        return cell
        
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        //selected row unzipped image url
        let unzippedImageUrl = collections[row].unzippedImagesUrl
        
        let imageCVC = storyboard?.instantiateViewController(withIdentifier: "ImageCollectionViewController") as! ImageCollectionViewController
        
        //sends unzipped image url to imageCVC
        imageCVC.unzippedImageUrl = unzippedImageUrl
        
        navigationController?.pushViewController(imageCVC, animated: true)
    }
    
}


