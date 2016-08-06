//
//  EditCollectionReusableView.swift
//  EmojiStickers
//
//  Created by Raul Riera on 26/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class EditCollectionReusableView: UICollectionReusableView {
	typealias ToggleEditModeHandler = (StickersViewController.CollectionViewStatus) -> Void

	@IBOutlet private weak var editButton: UIButton! {
		didSet {
			let buttonTitle = NSLocalizedString("Edit", comment: "Button when the user wants to start editing the stickers")
			editButton.setTitle(buttonTitle, for: .normal)
		}
	}

	static let reuseIdentifier = "EditCollectionReusableView"
	var toggleEditModeHandler: ToggleEditModeHandler?
	var collectionViewStatus: StickersViewController.CollectionViewStatus = .browsing

	@IBAction func didTapEdit(_ sender: UIButton) {
		let buttonTitle: String
		
		switch collectionViewStatus {
		case .browsing:
			buttonTitle = NSLocalizedString("Done", comment: "Button when the user wants to stop editing the stickers")
			collectionViewStatus = .editing
		case .editing:
			buttonTitle = NSLocalizedString("Edit", comment: "Button when the user wants to start editing the stickers")
			collectionViewStatus = .browsing
		}

		sender.setTitle(buttonTitle, for: .normal)
		toggleEditModeHandler?(collectionViewStatus)
	}
}
