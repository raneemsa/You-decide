//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//


import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoViewCell"
    
    var photoUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
