//
//  ViewController.swift
//  DadsApp
//
//  Created by Wayne Rumble on 05/04/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    let itemsPerRow: CGFloat = 2
    let file = Bundle.main.url(forResource: "DadsImages", withExtension: nil)!
    
    var imageURLs = [URL]()
    var selectedImage = UIImageView()
    var selectedImageBackgroundView = UIView()
    var pan: UIPanGestureRecognizer!
    var pinch: UIPinchGestureRecognizer!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        setGestureRecognizers()
        getImageNames()
    }
    
    func setCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func getImageNames() {
        
        if let path = Bundle.main.resourcePath {
            
            let imagePath = path + "/DadsImages"
            let url = NSURL(fileURLWithPath: imagePath)
            let fileManager = FileManager.default
            
            let properties = [URLResourceKey.localizedNameKey,
                              URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
            
            do {
                imageURLs = try fileManager.contentsOfDirectory(at: url as URL, includingPropertiesForKeys: properties, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                
                imageURLs.sort { $0.absoluteString.compare(
                    $1.absoluteString, options: .numeric) == .orderedAscending
                }
                
            } catch let error1 as NSError {
                
                print(error1.description)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let imageName = imageURLs[indexPath.row].deletingPathExtension().lastPathComponent
        
        cell.backgroundColor = .clear
        cell.imageView.image = UIImage(contentsOfFile: imageURLs[indexPath.row].path)!
        cell.nameLabel.text = imageName
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        addZoomedImage(indexPath.row)
        addGestureToImage()
        addBackGroundView()
        
        view.addSubview(selectedImage)
    }
    
    func addZoomedImage(_ indexPath: Int) {
        
        selectedImage.image = UIImage(contentsOfFile: imageURLs[indexPath].path)!
        selectedImage.frame = view.frame
        
        setImage()
    }
    
    func setImage() {
        
        selectedImage.contentMode = .scaleAspectFit
        selectedImage.isUserInteractionEnabled = true
    }
    
    func addGestureToImage() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        
        selectedImage.addGestureRecognizer(tap)
        selectedImage.addGestureRecognizer(pinch)
        selectedImage.addGestureRecognizer(pan)
    }
    
    func addBackGroundView() {
        
        selectedImageBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        selectedImageBackgroundView.frame = view.frame
        
        view.addSubview(selectedImageBackgroundView)
    }
    
    func dismissImage() {
        
        selectedImageBackgroundView.removeFromSuperview()
        selectedImage.removeFromSuperview()
    }
    
    func setGestureRecognizers() {
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDetected))
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGestureDetected))
        
        pan.delegate = self
        pinch.delegate = self
    }
    
    //Allow pan movements on image
    func panGestureDetected(_ recognizer: UIPanGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let translation: CGPoint = recognizer.translation(in: recognizer.view)
            recognizer.view?.transform = (recognizer.view?.transform.translatedBy(x: translation.x, y: translation.y))!
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }
    
    //Allow pinch movements on image
    func pinchGestureDetected(_ recognizer: UIPinchGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let scale: CGFloat = recognizer.scale
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: scale, y: scale))!
            recognizer.scale = 1.0
        }
    }
    
    //Recognise multiple gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }

}

