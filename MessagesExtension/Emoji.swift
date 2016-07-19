//
//  Emmoji.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

struct Emoji {
    let uuid: UUID
    let image: UIImage?
}

/**
 Extends `Emoji` to make it `Equatable`.
 */
extension Emoji: Equatable {}

func ==(lhs: Emoji, rhs: Emoji) -> Bool {
    return lhs.uuid == rhs.uuid
}
