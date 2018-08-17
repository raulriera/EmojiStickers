//
//  EmojiSticker.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

struct EmojiSticker: Equatable {
    let uuid: UUID
    let image: UIImage?

	static func ==(lhs: EmojiSticker, rhs: EmojiSticker) -> Bool {
		return lhs.uuid == rhs.uuid
	}
}
