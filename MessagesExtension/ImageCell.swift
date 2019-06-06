//
//  ImageCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 08/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
	let selectedColor: UIColor = .systemYellow
	let deselectedColor: UIColor = .systemGray
	
	@IBOutlet private weak var imageView: UIImageView! {
		didSet {
			imageView?.tintColor = deselectedColor
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
				imageView?.tintColor = selectedColor
			} else {
				imageView?.tintColor = deselectedColor
			}
		}
	}
}
