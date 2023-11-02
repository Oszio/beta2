//
//  ImageCache.swift
//  beta2
//
//  Created by Oskar Almå on 2023-11-02.
//

import Kingfisher
import UIKit
import FirebaseStorage

class MySocialMediaController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    func loadImageFromFirebase() {
        // Assuming `imagePath` is the path to your image in Firebase Storage
        // and you have the URL saved in Firestore
        let imagePath = "path/to/your/image.jpg"
        let storageRef = Storage.storage().reference(withPath: imagePath)

        // Fetch the download URL
        storageRef.downloadURL { url, error in
            if let error = error {
                // Handle any errors
                print(error)
                return
            }
            if let url = url {
                // Use Kingfisher to download and cache the image
                self.imageView.kf.setImage(with: url)
            }
        }
    }
}

