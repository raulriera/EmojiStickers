//
//  EmojiView.swift
//  EmojiStickers
//
//  Created by Raul Riera on 25/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class EmojiView: UIImageView {
	
	// MARK: Properties
	let defaultSize = CGSize(width: 250, height: 250)
	let character: String
	
	// MARK: Initialisers
	
	init(character: String) {
		self.character = character
		super.init(frame: CGRect(origin: .zero, size: defaultSize))
		backgroundColor = .clear
		isUserInteractionEnabled = true
		
		isAccessibilityElement = true
		accessibilityLabel = "\(character) emoji"
		accessibilityHint = "You can scale, rotate, move this emoji"
		
		updateImageFromPDF()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setNeedsImageUpdate() {
		updateImageFromPDF()
	}
	
	// MARK: Private
	
	private func updateImageFromPDF() {
		if let urlForDocument = Bundle.main.url(forResource: character.utf, withExtension: "pdf") {
			let document = CGPDFDocument(urlForDocument)!
			let image = UIImage(document: document, at: bounds.size)
			self.image = image
		} else {
			print("Did not find document for \(character.utf)")
		}
	}
}
