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
protocol EmojiCategoryViewControllerDelegate: AnyObject {
	/// Called when the user selects an emoji in the `EmojiCategoryViewController`.
	func emojiCategoryViewController(_ controller: EmojiCategoryViewController, didSelect emoji: Emoji, at rect: CGRect)
}

final class EmojiCategoryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	static let storyboardIdentifier = "EmojiCategoryViewController"
	static let placeholderImage: UIImage = #imageLiteral(resourceName: "placeholder_image")
	public var category: EmojiDictionary.Category! {
		didSet {
			collectionView?.reloadData()
		}
	}
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
		
		collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		let offsetCache = EmojiCategoryOffsetCache.load()
		// Hack the planet!, we want to restore the last offset used. Check if
		// its different than zero. If so, hide the collection view to prevent a 
		// "visual jump" to the offset. Lastly, wrap everythign in a timer so 
		// we can actually scroll there, otherwise it doesn't do anything.
		if offsetCache.offset != .zero {
			self.collectionView?.isHidden = true

			Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
				self.collectionView?.setContentOffset(offsetCache.offset, animated: false)
				self.collectionView?.isHidden = false
				offsetCache.save(offset: .zero)
			}
		}
	}
	
	// MARK: Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Show Skin Tones", let sender = sender as? UIView, let controller = segue.destination as? SkinToneViewController {
			
			controller.onSelected = { [weak self] _ in
				self?.collectionView?.reloadData()
				controller.dismiss(animated: true, completion: nil)
			}
			
			controller.modalPresentationStyle = .popover
			controller.popoverPresentationController?.delegate = self
			controller.popoverPresentationController?.sourceView = sender
			controller.popoverPresentationController?.sourceRect = sender.bounds.insetBy(dx: sender.bounds.midX, dy: sender.bounds.midY)
		}
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
		if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCharacterCell, let emoji = cell.emoji {
			let attributes = collectionView.layoutAttributesForItem(at: indexPath)
			let rect = collectionView.convert(attributes?.frame ?? CGRect.zero, to: collectionView.superview)

			// Save the current scroll position
			EmojiCategoryOffsetCache.load().save(offset: collectionView.contentOffset)

			// Notify the delegate that we selected an emoji
			delegate?.emojiCategoryViewController(self, didSelect: emoji, at: rect)
		}
	}
	
	// The following methods take care of long pressing the cells and display
	// an option controller, we will override this and present out skin tone selector
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCharacterCell, let emoji = cell.emoji, emoji.canHaveSkinToneModifier {
			performSegue(withIdentifier: "Show Skin Tones", sender: cell)
		}
		
		// Return an empty configuration to indicate that no action can take place
		return UIContextMenuConfiguration()
	}
			
	// MARK: UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return category.value.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return dequeueEmojiCharacterCell(at: indexPath)
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PoweredByDisclaimer", for: indexPath)

		// Hide the disclaimer if there are just a few emojis (so that the recent tab doesn't look ugly
		view.isHidden = collectionView.numberOfItems(inSection: 0) <= 50

		return view
	}
	
	// MARK: Convenience
	
	private func dequeueEmojiCharacterCell(at indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiCharacterCell.reuseIdentifier, for: indexPath) as? EmojiCharacterCell else { fatalError("Unable to dequeue am EmojiCharacterCell") }
		
		let emoji: Emoji = category.value[indexPath.row]
		let skinTone = SkinToneCache.load().tone
		
		let emojiView = UnsavedEmojiSticker(character: emoji, tone: skinTone) {
			let emojiHexcode = emoji.applying(skinTone: skinTone)
			
			if let urlForDocument = Bundle.main.url(forResource: emojiHexcode, withExtension: "pdf") {
				let document = CGPDFDocument(urlForDocument as CFURL)!
				let image = UIImage(document: document)
				return image
			} else {
				print("Did not find document for \(emoji.hexcode)")
			}
			
			return EmojiCategoryViewController.placeholderImage
		}
		
		// Use a placeholder sticker while we fetch the real one from the cache.
		let cache = ImageCache.cache
		cell.emoji = emoji
		cell.characterImage.image = cache.placeholderImage
		
		// Fetch the sticker for the emoji from the cache.
		cache.image(for: emojiView) { image in
			OperationQueue.main.addOperation {
				// Only update the cell if the emoji is the correct one
				guard cell.emoji == emoji else { return }
				cell.characterImage.image = image
			}
		}
		
		return cell
	}
}

extension EmojiCategoryViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}
