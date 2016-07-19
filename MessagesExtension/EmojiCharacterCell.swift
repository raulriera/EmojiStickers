//
//  EmojiCharacterCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 25/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class EmojiCharacterCell: UICollectionViewCell {
	@IBOutlet weak var characterImage: UIImageView!
	
	static let reuseIdentifier = "EmojiCharacterCell"
	
	var representedEmoji: String? {
		didSet {
			guard let representedEmoji = representedEmoji else { return }
			
			isAccessibilityElement = true
			accessibilityValue = "\(representedEmoji) emoji"
			accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitButton
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		characterImage.image = nil
	}
}

