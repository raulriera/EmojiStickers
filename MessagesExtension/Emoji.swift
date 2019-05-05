//
//  Emoji.swift
//  EmojiKit
//
//  Created by Raul Riera on 2018-06-17.
//  Copyright © 2018 Raul Riera. All rights reserved.
//

import Foundation

public struct Skin: Codable, Equatable {
	public let hexcode: String
	public let emoji: String
}

public struct Emoji: Codable, Equatable {
	public let name: String
	public let hexcode: String
	public let keywords: [String]
	public let emoji: String
	public let skins: [Skin]
	
	public var canHaveSkinToneModifier: Bool {
		return skins.isEmpty == false
	}
	
	public func applying(skinTone: Int) -> String {
		guard skins.isEmpty == false else { return hexcode }
		
		if skinTone != 0 {
			return skins[skinTone-1].hexcode
		} else {
			return self.hexcode
		}
	}
}
