//
//  EmojiOne.swift
//  EmojiStickers
//
//  Created by Raul Riera on 01/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

struct EmojiOne {
	let character: String
	let image: () -> UIImage
	
	init(character: String, image: @escaping () -> UIImage) {
		self.character = character
		self.image = image
	}
}

extension EmojiOne: Cachable {
	var identifier: String {
		return character.utf
	}
}
