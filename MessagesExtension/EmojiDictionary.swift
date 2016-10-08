//
//  EmojiDictionary.swift
//  EmojiStickers
//
//  Created by Raul Riera on 27/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

struct EmojiDictionary {
	// These emojis shouldn't have a skin tone modifier, but they act like they do
	// so skip these
	static let blacklist = ["😀", "😬", "😁", "😂", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "🙂", "🙃", "☺️", "😋", "😌", "😍", "😘", "😗", "😙", "😚", "😜", "😝", "😛", "🤑", "🤓", "😎", "🤗", "😏", "😶", "😐", "😑", "😒", "🙄", "🤔", "😳", "😞", "😟", "😠", "😡", "😔", "😕", "🙁", "☹️", "😣", "😖", "😫", "😩", "😤", "😮", "😱", "😨", "😰", "😯", "😦", "😧", "😢", "😥", "😪", "😓", "😭", "😵", "😲", "🤐", "😷", "🤒", "🤕", "😴", "😈", "👿", "🏂", "🤕🎃", "👨🎃", "👩🎃"]
	let categories: [Category]
	
	struct Category {
		let key: Keys
		let value: [String]
		
		var count: Int {
			return value.count
		}
	}
	
	enum Keys: String {
		case recent = "Recent"
		case people = "People"
		case nature = "Nature"
		case foodAndDrinks = "FoodAndDrinks"
		case activitiesAndSports = "ActivitiesAndSports"
		case travelAndPlaces = "TravelAndPlaces"
		case objects = "Objects"
		case symbols = "Symbols"
		case flags = "Flags"
		case seasons = "Seasons"
	}
	
	init() {
		let path = Bundle.main.path(forResource: "EmojisList", ofType: "plist")!
		let dictionary = NSDictionary(contentsOfFile: path)!
		let contentsOfFile = dictionary as! [String: [String]]
		
		self.categories = [
			Category(key: .recent, value: RecentEmojiCache.load().emojis.reversed()),
			Category(key: .people, value: contentsOfFile[Keys.people.rawValue]!),
			Category(key: .nature, value: contentsOfFile[Keys.nature.rawValue]!),
			Category(key: .foodAndDrinks, value: contentsOfFile[Keys.foodAndDrinks.rawValue]!),
			Category(key: .activitiesAndSports, value: contentsOfFile[Keys.activitiesAndSports.rawValue]!),
			Category(key: .travelAndPlaces, value: contentsOfFile[Keys.travelAndPlaces.rawValue]!),
			Category(key: .objects, value: contentsOfFile[Keys.objects.rawValue]!),
			Category(key: .symbols, value: contentsOfFile[Keys.symbols.rawValue]!),
			Category(key: .flags, value: contentsOfFile[Keys.flags.rawValue]!),
			Category(key: .seasons, value: contentsOfFile[Keys.seasons.rawValue]!)
		]
	}
}

func ==(lhs: EmojiDictionary.Category, rhs: EmojiDictionary.Category) -> Bool {
	return lhs.key.rawValue == rhs.key.rawValue
}
