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

	@IBOutlet private weak var editButton: UIButton!

	static let reuseIdentifier = "EditCollectionReusableView"
	var toggleEditModeHandler: ToggleEditModeHandler?
	var collectionViewStatus: StickersViewController.CollectionViewStatus = .browsing

	@IBAction func didTapEdit(_ sender: UIButton) {
		switch collectionViewStatus {
		case .browsing:
			sender.setTitle("Done", for: .normal)
			collectionViewStatus = .editing
		case .editing:
			sender.setTitle("Edit", for: .normal)
			collectionViewStatus = .browsing
		}

		toggleEditModeHandler?(collectionViewStatus)
	}
}
