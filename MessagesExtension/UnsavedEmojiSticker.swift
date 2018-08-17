//
//  UnsavedEmojiSticker.swift
//  EmojiStickers
//
//  Created by Raul Riera on 01/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

struct UnsavedEmojiSticker {
	let character: Emoji
	let tone: Int
	let image: () -> UIImage
	
	init(character: Emoji, tone: Int, image: @escaping () -> UIImage) {
		self.character = character
		self.tone = tone
		self.image = image
	}
}

extension UnsavedEmojiSticker: Cachable {
	var identifier: String {
		return character.applying(skinTone: tone)
	}
}
