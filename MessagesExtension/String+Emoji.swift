//
//  String+Emoji.swift
//  EmojiStickers
//
//  Created by Raúl Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

extension String {
	var emojiSkinToneModifiers: [String] {
		return [ "🏻", "🏼", "🏽", "🏾", "🏿" ]
	}
	
	var emojiVisibleLength: Int {
		var count = 0
		enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) { _ in count = count + 1 }
		return count
	}
	
	var emojiUnmodified: String {
		if characters.isEmpty {
			return ""
		}
		
		return "\(characters.first!)"
	}
	
	var canHaveSkinToneModifier: Bool {
		// These emojis shouldn't have a skin tone modifier, but they act like they do
		// so skip these
		let blacklist = ["😀", "😬", "😁", "😂", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "🙂", "🙃", "☺️", "😋", "😌", "😍", "😘", "😗", "😙", "😚", "😜", "😝", "😛", "🤑", "🤓", "😎", "🤗", "😏", "😶", "😐", "😑", "😒", "🙄", "🤔", "😳", "😞", "😟", "😠", "😡", "😔", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "😤", "😮", "😱", "😨", "😰", "😯", "😦", "😧", "😢", "😥", "😪", "😓", "😭", "😵", "😲", "🤐", "😷", "🤒", "🤕", "😴", "😈", "👿"]
		
		guard !blacklist.contains(self) else { return false }

		if characters.count == 0 {
			return false
		}
		
		let modified = emojiUnmodified + emojiSkinToneModifiers[0]
		return modified.emojiVisibleLength == 1
	}
	
	var utf: String {
		// Remove the "fe0f" that seems to be added to some of them
		return unicodeScalars.map { String($0.value, radix: 16, uppercase: false) }.filter { $0 != "fe0f" && $0 != "200d" }.joined(separator: "-")
	}
}
