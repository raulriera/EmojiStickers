//
//  EmojiCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

class EmojiCell: UICollectionViewCell {
	@IBOutlet weak var stickerView: MSStickerView!
		
    static let reuseIdentifier = "EmojiCell"
	var representedEmoji: Emoji?
}
