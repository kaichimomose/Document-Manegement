//
//  ImageCollectionViewController.swift
//  Document-Management
//
//  Created by Kaichi Momose on 2018/01/21.
//  Copyright © 2018 Kaichi Momose. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var unzippedImageUrl: URL?
    var imageUrls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ImageCell", bundle: .main), forCellWithReuseIdentifier: "ImageCell")
        
        do {
            if let url = self.unzippedImageUrl {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                let jpegFiles = directoryContents.filter{ $0.pathExtension == "jpg" || $0.pathExtension == "jpeg"}
                self.imageUrls = jpegFiles
            }
        } catch {
            print("\(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ImageCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let row = indexPath.row
        cell.jpegImage.image = loadImage(fileURL: self.imageUrls[row])
        return cell
    }
    
}
