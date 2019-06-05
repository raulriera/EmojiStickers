//
//  ImageCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 08/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
	@IBOutlet private weak var imageView: UIImageView! {
		didSet {
			imageView?.tintColor = .systemGray
		}
	}
	static let reuseIdentifier = "ImageCell"
	
	var category: String = "" {
		didSet {
			imageView.image = UIImage(named: category)
			
			isAccessibilityElement = true
			accessibilityValue = "\(category.description) category"
			accessibilityTraits = [.image, .button]
		}
	}
	
	override var isSelected: Bool {
		didSet {
			if isSelected {
				imageView?.tintColor = tintColor
			} else {
				imageView?.tintColor = .systemGray
			}
		}
	}
}
