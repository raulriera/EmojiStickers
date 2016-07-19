//
//  String+Extensions.swift
//  EmojiStickers
//
//  Created by Raul Riera on 09/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension String {
	func humanize() -> String {
		let lowercaseLetters = components(separatedBy: CharacterSet.uppercaseLetters).filter { !$0.isEmpty }
		let uppercaseLetters = components(separatedBy: CharacterSet.lowercaseLetters).filter { !$0.isEmpty }
		
		var sentence: [String] = []
		
		for (index, _) in uppercaseLetters.enumerated() {
			sentence.append(uppercaseLetters[index] + lowercaseLetters[index])
		}
		
		return sentence.joined(separator: " ")
	}
}
