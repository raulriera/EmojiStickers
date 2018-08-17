//
//  EmojiView.swift
//  EmojiStickers
//
//  Created by Raul Riera on 25/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

final class EmojiView: UIImageView {
	
	// MARK: Properties

	let defaultSize = CGSize(width: 250, height: 250)
	let hexcode: String
	var isFlipped: Bool {
		return image?.imageOrientation == .upMirrored
	}
	var isSelected: Bool {
		didSet {
			if isSelected {
				layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
				layer.borderWidth = 1.0
				layer.cornerRadius = 6
			} else {
				layer.borderColor = UIColor.black.cgColor
				layer.borderWidth = 0.0
				layer.cornerRadius = 0
			}
		}
	}
	
	// MARK: Initialisers
	
	init(hexcode: String) {
		self.hexcode = hexcode
		self.isSelected = true

		super.init(frame: CGRect(origin: .zero, size: defaultSize))

		backgroundColor = .clear
		isUserInteractionEnabled = true
		
		isAccessibilityElement = true
		accessibilityHint = "You can scale, rotate, move this emoji"
		
		updateImageFromPDF()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK:

	func setNeedsImageUpdate() {
		updateImageFromPDF()
	}

	func flipped() {
		if isFlipped {
			image = UIImage(cgImage: image!.cgImage!, scale: 0, orientation: .up)
		} else {
			image = UIImage(cgImage: image!.cgImage!, scale: 0, orientation: .upMirrored)
		}
	}
	
	// MARK: Private
	
	private func updateImageFromPDF() {
		if let urlForDocument = Bundle.main.url(forResource: hexcode, withExtension: "pdf") {
			let document = CGPDFDocument(urlForDocument as CFURL)!
			let image = UIImage(document: document, at: bounds.size)

			// If the image was already rendered, maintain the current "flip" state
			self.image = isFlipped ? UIImage(cgImage: image.cgImage!, scale: 0, orientation: .upMirrored) : image
		} else {
			print("Did not find document for \(hexcode)")
		}
	}
}
