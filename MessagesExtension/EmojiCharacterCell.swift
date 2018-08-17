//
//  EmojiCharacterCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 25/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

final class EmojiCharacterCell: UICollectionViewCell {
	@IBOutlet weak var characterImage: UIImageView!
	
	static let reuseIdentifier = "EmojiCharacterCell"
	
	var emoji: Emoji? {
		didSet {
			guard let emoji = emoji else { return }
			
			isAccessibilityElement = true
			accessibilityValue = emoji.name
			accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitButton
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		characterImage.image = nil
	}
}
