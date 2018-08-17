//
//  EmojiStickerCells.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

final class EmojiStickerCell: UICollectionViewCell {
	typealias DeleteHandler = (EmojiSticker) -> Void

	@IBOutlet weak var stickerView: MSStickerView!
	@IBOutlet weak var deleteButton: UIButton!

    static let reuseIdentifier = "EmojiStickerCell"
	var representedEmoji: EmojiSticker?
	var collectionViewStatus: StickersViewController.CollectionViewStatus = .browsing {
		didSet {
			guard collectionViewStatus != oldValue else { return }
			updateStatus()
		}
	}
	var deleteHandler: DeleteHandler?

	override func prepareForReuse() {
		super.prepareForReuse()

		if case .editing = collectionViewStatus {
			startJiggling()
		}
	}

	// MARK: IBActions

	@IBAction func deleteTapped(_ sender: UIButton) {
		guard let representedEmoji = representedEmoji else { return }
		deleteHandler?(representedEmoji)
	}

	// MARK: Private

	private func updateStatus() {
		if collectionViewStatus == .browsing {
			stickerView.isUserInteractionEnabled = true
			deleteButton.isUserInteractionEnabled = false
			deleteButton.isHidden = true
			stopJiggling()
		} else {
			stickerView.isUserInteractionEnabled = false
			deleteButton.isUserInteractionEnabled = true
			deleteButton.isHidden = false
			startJiggling()
		}
	}

	private func startJiggling() {
		for animation in CAKeyframeAnimation.jiggle() {
			contentView.layer.add(animation, forKey: animation.keyPath)
		}
	}

	private func stopJiggling() {
		contentView.layer.removeAllAnimations()
	}
}

