//
//  EmojiCategoryViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 02/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

/**
A delegate protocol for the `EmojiCategoryViewController` class.
*/
protocol EmojiCategoryViewControllerDelegate: class {
	/// Called when the user selects an emoji in the `EmojiCategoryViewController`.
	func emojiCategoryViewController(_ controller: EmojiCategoryViewController, didSelect emoji: String)
}

class EmojiCategoryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	static let storyboardIdentifier = "EmojiCategoryViewController"
	static let placeholderImage: UIImage = #imageLiteral(resourceName: "placeholder_image")
	var category: EmojiDictionary.Category!
	weak var delegate: EmojiCategoryViewControllerDelegate?
	
	private var cellSize: CGSize = CGSize(width: 50, height: 50)
	private var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	private var minimumInteritemSpacing: CGFloat = 20
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView?.isPrefetchingEnabled = true
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		guard let collectionView = collectionView else { return }
		
		if traitCollection.horizontalSizeClass == .regular {
			cellSize = CGSize(width: 75, height: 75)
			sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
			minimumInteritemSpacing = 40
		} else {
			cellSize = CGSize(width: 50, height: 50)
			sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
			minimumInteritemSpacing = 20
		}
		
		collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return cellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInset
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return minimumInteritemSpacing
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let emoji = category.value[indexPath.row]
		delegate?.emojiCategoryViewController(self, didSelect: emoji)
	}
	
	// MARK: UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return category.value.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return dequeueEmojiCharacterCell(at: indexPath)
	}
	
	// MARK: Convenience
	
	private func dequeueEmojiCharacterCell(at indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiCharacterCell.reuseIdentifier, for: indexPath) as? EmojiCharacterCell else { fatalError("Unable to dequeue am EmojiCharacterCell") }
		
		let emojiCharacter = category.value[indexPath.row]
		
		let emojiOne = EmojiOne(character: emojiCharacter) {
			if let urlForDocument = Bundle.main.urlForResource(emojiCharacter.utf, withExtension: "pdf") {
				let document = CGPDFDocument(urlForDocument)!
				let image = UIImage(document: document)
				return image
			} else {
				print("Did not find document for \(emojiCharacter)")
			}
			
			return EmojiCategoryViewController.placeholderImage
		}
		
		// Use a placeholder sticker while we fetch the real one from the cache.
		let cache = ImageCache.cache
		cell.representedEmoji = emojiCharacter
		cell.characterImage.image = cache.placeholderImage
		
		// Fetch the sticker for the emoji from the cache.
		cache.image(for: emojiOne) { image in
			OperationQueue.main.addOperation {
				// Only update the cell if the emoji is the correct one
				guard cell.representedEmoji == emojiCharacter else { return }
				cell.characterImage.image = image
			}
		}
		
		return cell
	}
}
