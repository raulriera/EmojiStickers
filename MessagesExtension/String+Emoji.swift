//
//  String+Emoji.swift
//  EmojiKit
//
//  Created by Raul Riera on 13/05/2017.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import Foundation

let toneModifiers = ["1f3fb", "1f3fc", "1f3fd", "1f3fe", "1f3ff"]
// 	[ "🏻", "🏼", "🏽", "🏾", "🏿" ]

extension Array where Iterator.Element: Equatable {
	@discardableResult
	public mutating func remove(where condition: (Iterator.Element) -> Bool) -> Iterator.Element? {
		guard let index = index(where: condition) else { return nil }
		return remove(at: Int(index))
	}

	@discardableResult
	public mutating func removeAll(where condition: (Iterator.Element) -> Bool) -> [Iterator.Element] {
		var result: [Iterator.Element] = []

		while let index = index(where: condition) {
			result.append(remove(at: index))
		}

		return result
	}
}

extension String {
	var emojiVisibleLength: Int {
		var count = 0
		enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) { _ in count = count + 1 }
		return count
	}

	var emojiUnmodified: String {
		if characters.isEmpty {
			return ""
		}

		var components = self.components(separatedBy: "-")
		let filtered = components.removeAll(where: { toneModifiers.contains($0) == false }).joined(separator: "-")

		return filtered
	}

	var canHaveSkinToneModifier: Bool {
		let copy = self.emojiUnmodified
		let blacklist = ["😀", "😬", "😁", "😂", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "🙂", "🙃", "☺️", "😋", "😌", "😍", "😘", "😗", "😙", "😚", "😜", "😝", "😛", "🤑", "🤓", "😎", "🤗", "😏", "😶", "😐", "😑", "😒", "🙄", "🤔", "😳", "😞", "😟", "😠", "😡", "😔", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "😤", "😮", "😱", "😨", "😰", "😯", "😦", "😧", "😢", "😥", "😪", "😓", "😭", "😵", "😲", "🤐", "😷", "🤒", "🤕", "😴", "😈", "👿", "🤝", "👯", "👫", "👭", "👬", "👪", "🛌", "🕴", "💃", "🕺", "🚶", "🏃", "👩‍❤️‍👩", "👨‍❤️‍👨", "👩‍❤️‍💋‍👩", "👨‍❤️‍💋‍👨", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧", "👩‍👩‍👦", "👩‍👩‍👧", "👩‍👩‍👧‍👦", "👩‍👩‍👦‍👦", "👩‍👩‍👧‍👧", "👨‍👨‍👦", "👨‍👨‍👧", "👨‍👨‍👧‍👦", "👨‍👨‍👦‍👦", "👨‍👨‍👧‍👧", "👩‍👦", "👩‍👧", "👩‍👧‍👦", "👩‍👦‍👦", "👩‍👧‍👧", "👨‍👦", "👨‍👧", "👨‍👧‍👦", "👨‍👦‍👦", "👨‍👧‍👧"].map { $0.utf }

		let whitelist = ["✌️", "☝️", "✍️", "🤟", "🤲", "👮‍♀️", "👷‍♀️", "💂‍♀️", "👩‍⚕️", "👨‍⚕️", "👩‍🌾", "👨‍🌾", "👩‍🍳", "👨‍🍳", "👩‍🎓", "👨‍🎓", "👩‍🎤", "👨‍🎤", "👩‍🏫", "👨‍🏫", "👩‍🏭", "👨‍🏭", "👩‍💻", "👨‍💻", "👩‍💼", "👨‍💼", "👩‍🔧", "👨‍🔧", "👩‍🔬", "👨‍🔬", "👩‍🎨", "👨‍🎨", "👩‍🚒", "👨‍🚒", "👩‍✈️", "👨‍✈️", "👩‍🚀", "👨‍🚀", "👩‍⚖️", "👨‍⚖️", "🙇‍♀️", "👱‍♀️", "💁‍♂️", "🙅‍♂️", "🙆‍♂️", "🙋‍♂️", "🤦‍♀️", "🤦‍♂️", "🤷‍♀️", "🤷‍♂️", "🙎‍♂️", "🙍‍♂️", "💇‍♂️", "💆‍♂️", "👳‍♀️", "🧒", "🧑", "🧓", "🧕", "🧔", "🤱", "🧙‍♀️", "🧙‍♂️", "🧚‍♀️", "🧚‍♂️", "🧛‍♀️", "🧛‍♂️", "🧜‍♀️", "🧜‍♂️", "🧝‍♀️", "🧝‍♂️", "🧖‍♀️", "🧖‍♂️", "🧗‍♀️", "🧗‍♂️", "🧘‍♀️", "🧘‍♂️"].map { $0.utf }
		guard !whitelist.contains(copy) else { return true }
		guard !blacklist.contains(copy) else { return false }

		if characters.count == 0 {
			return false
		}

		let modified = copy + "-" + toneModifiers[0]
		return modified.encoded.emojiVisibleLength == 1
	}

	var utf: String {
		return unicodeScalars.map { String($0.value, radix: 16, uppercase: false) }.joined(separator: "-")
	}

	func applying(skinTone: String) -> String {
		guard skinTone.isEmpty == false else { return self.emojiUnmodified }
		var components = self.emojiUnmodified.components(separatedBy: "-")
		components.insert(skinTone, at: 1)
		return components.joined(separator: "-")
	}

	var encoded: String {
		return self.components(separatedBy: "-").flatMap { utf in
			guard let asInt = Int(utf, radix: 16) else { return nil }
			guard let scalar = UnicodeScalar(asInt) else { return nil }
			return String(scalar)
			}.joined()
	}
}
