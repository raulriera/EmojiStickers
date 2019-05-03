//
//  EmojiDictionary.swift
//  EmojiKit
//
//  Created by Raul Riera on 2018-08-12.
//  Copyright © 2018 Raul Riera. All rights reserved.
//

import Foundation

public struct EmojiDictionary {
	public let categories: [Category]
	
	public struct Category: Equatable {
		public let key: Keys
		public let value: [Emoji]
		
		public var count: Int {
			return value.count
		}
	}
	
	public enum Keys: String {
		case recent = "Recent"
		case people = "Smileys & People"
		case nature = "Animals & Nature"
		case foodAndDrinks = "Food & Drink"
		case activitiesAndSports = "Activities"
		case travelAndPlaces = "Travel & Places"
		case objects = "Objects"
		case symbols = "Symbols"
		case flags = "Flags"
		case custom = "Custom"
	}
	
	public init() {
		let bundle = Bundle.main
		let url = bundle.url(forResource: "EmojiList", withExtension: "json")!
		let data = try! Data(contentsOf: url)
		let contentsOfFile = try! JSONDecoder().decode([String: [Emoji]].self, from: data)
		
		self.categories = [
			Category(key: .recent, value: RecentEmojiCache.load().emojis.reversed()),
			Category(key: .people, value: contentsOfFile[Keys.people.rawValue]!),
			Category(key: .nature, value: contentsOfFile[Keys.nature.rawValue]!),
			Category(key: .foodAndDrinks, value: contentsOfFile[Keys.foodAndDrinks.rawValue]!),
			Category(key: .activitiesAndSports, value: contentsOfFile[Keys.activitiesAndSports.rawValue]!),
			Category(key: .travelAndPlaces, value: contentsOfFile[Keys.travelAndPlaces.rawValue]!),
			Category(key: .objects, value: contentsOfFile[Keys.objects.rawValue]!),
			Category(key: .symbols, value: contentsOfFile[Keys.symbols.rawValue]!),
			Category(key: .flags, value: contentsOfFile[Keys.flags.rawValue]!)
		]
	}
	
	func search(query: String) -> [Emoji] {
		var categoriesWithoutRecent = categories.dropFirst()
		categoriesWithoutRecent.append(customCategory())
		
		let filtered = categoriesWithoutRecent.flatMap { category in
			category.value.filter { emoji in
				// Search all keywords and the emoji name
				let searchTerms = emoji.keywords + [emoji.name]
				return searchTerms.contains(where: { term -> Bool in
					return term.lowercased().range(of: query.lowercased()) != nil
				})
			}
		}
		
		return filtered
	}
	
	// Add any crazy emojis we want to support that are only visible when
	// using the search interface
	func customCategory() -> Category {
		let emojis = [
			Emoji(name: "",
				  hexcode: "1f346-1f351",
				  keywords: ["caio"],
				  emoji: "",
				  skins: []),
			Emoji(name: "Flag of Quebec",
				  hexcode: "1f1e8-1f1e6-1f1eb-1f1f7",
				  keywords: ["quebec, marjolaine"],
				  emoji: "",
				  skins: [])
		]
		
		return EmojiDictionary.Category(key: .custom, value: emojis)
	}
}
