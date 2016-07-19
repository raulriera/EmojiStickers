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
			imageView?.tintColor = #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5019607843, alpha: 1)
		}
	}
	static let reuseIdentifier = "ImageCell"
	
	var category: String = "" {
		didSet {
			imageView.image = UIImage(named: category)
			
			isAccessibilityElement = true
			accessibilityValue = "\(category.humanize()) category"
			accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitButton
		}
	}
	
	override var isSelected: Bool {
		didSet {
			if isSelected {
				imageView?.tintColor = tintColor
			} else {
				imageView?.tintColor = #colorLiteral(red: 0.4235294118, green: 0.4588235294, blue: 0.5019607843, alpha: 1)
			}
		}
	}
}
