//
//  EmojiCell.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

class EmojiCell: UICollectionViewCell {
	@IBOutlet weak var stickerView: MSStickerView!
	@IBOutlet private weak var deleteButton: UIButton!

    static let reuseIdentifier = "EmojiCell"
	var representedEmoji: Emoji?
	var collectionViewStatus: StickersViewController.CollectionViewStatus = .browsing {
		didSet {
			updateStatus()
		}
	}

	// MARK: IBActions

	@IBAction func deleteTapped(_ sender: UIButton) {
		print("DELETE TAPPED")
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
			contentView.layer.add(animation, forKey: nil)
		}
	}

	private func stopJiggling() {
		contentView.layer.removeAllAnimations()
	}
}

