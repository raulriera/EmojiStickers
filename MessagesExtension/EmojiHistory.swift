//
//  EmojiHistory.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

struct EmojiHistory {
    // MARK: Properties
    
    fileprivate static let maximumHistorySize = 250
    fileprivate static let userDefaultsKey = "emojiHistory"
    
    /// An array of previously created `Emoji`.
    fileprivate var emojis: [EmojiSticker]
    
    var count: Int {
        return emojis.count
    }
    
    subscript(index: Int) -> EmojiSticker {
        return emojis[index]
    }
    
    // MARK: Initialization
    
    /**
     `EmojiHistory`'s initializer is marked as private. Instead instances should
     be loaded via the `load` method.
     */
    private init(emojis: [EmojiSticker]) {
        self.emojis = emojis
    }
    
    /// Loads previously created `Emoji`s and returns a `EmojiHistory` instance.
    static func load() -> EmojiHistory {
        var emojis = [EmojiSticker]()
        let defaults = UserDefaults.standard
        
        if let savedEmojis = defaults.object(forKey: EmojiHistory.userDefaultsKey) as? [String] {
            emojis = savedEmojis.compactMap { uuidString in
                guard let uuid = UUID(uuidString: uuidString) else { return nil }
				
                return EmojiSticker(uuid: uuid, image: nil)
            }
        }
        
        return EmojiHistory(emojis: emojis)
    }
    
    /// Saves the history.
    func save() {
        // Save a maximum number of stickers.
        let emojisToSave = emojis.suffix(EmojiHistory.maximumHistorySize)
        
        // Map the stickers to an array of UUID strings.
        let stickersUUIDStrings: [String] = emojisToSave.map { $0.uuid.uuidString }
        
        let defaults = UserDefaults.standard
        defaults.set(stickersUUIDStrings as AnyObject, forKey: EmojiHistory.userDefaultsKey)
    }
    
    mutating func append(_ emoji: EmojiSticker) {
        /*
         Filter any existing instances of the new emoji from the current
         history before adding it to the end of the history.
         */
        var newEmojis = self.emojis.filter { $0 != emoji }
        newEmojis.append(emoji)
        
        emojis = newEmojis
    }

	mutating func update(with emojis: [EmojiSticker]) {
		self.emojis = emojis
		save()
	}
}

/**
Extends `EmojiHistory` to conform to the `Sequence` protocol so it can be used
in for..in statements.
*/
extension EmojiHistory: Sequence {
	typealias Iterator = AnyIterator<EmojiSticker>

	func makeIterator() -> Iterator {
		var index = 0

		return Iterator {
			guard index < self.emojis.count else { return nil }

			let emoji = self.emojis[index]
			index += 1

			return emoji
		}
	}
}
