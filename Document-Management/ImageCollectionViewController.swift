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

        //collectionView setup
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: .main), forCellWithReuseIdentifier: "ImageCell")
        
        //get image urls from a unzipped image url
        guard let imageUrls = getImageUrls(url: self.unzippedImageUrl) else {return}
        self.imageUrls = imageUrls
    }

    //get file urls from a folder url
    private func getImageUrls(url: URL?) -> [URL]? {
        do {
            guard let url = url else {return nil}
            
            //get all contents in a folder
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
            //filering all contents by path extension
            let jpegFiles = directoryContents.filter{ $0.pathExtension == "jpg" || $0.pathExtension == "jpeg"}
            
            return jpegFiles
        } catch {
            print("\(error)")
        }
        return nil
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
        //shows the same number of cells as the number of image urls
        return self.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let row = indexPath.row
        
        //load a image with a image url
        cell.jpegImage.image = loadImage(fileURL: self.imageUrls[row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let showImageVC = storyboard?.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        showImageVC.image = loadImage(fileURL: self.imageUrls[row])
        navigationController?.pushViewController(showImageVC, animated: true)
    }
    
}
