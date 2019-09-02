//
//  EmojiCategoryPickerViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 08/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

protocol EmojiCategoryPickerViewControllerDelegate: class {
	/// Called when the user selects an emoji in the `EmojiCategoryPickerViewController`.
	func emojiCategoryPickerViewController(_ controller: EmojiCategoryPickerViewController, didChangePageTo page: Int)
}

final class EmojiCategoryPickerViewController: UICollectionViewController {
	weak var delegate: EmojiCategoryPickerViewControllerDelegate?
	static let storyboardIdentifier = "EmojiCategoryPickerViewController"
	var categories: [EmojiDictionary.Category] = [] {
		didSet {
			collectionView?.reloadData()
		}
	}
	var selectedCategory: Int = 0 {
		didSet {
			Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
				let indexPath = IndexPath(item: self.selectedCategory, section: 0)
				self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
			}
		}
	}
	
	// MARK: Lifecycle
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	// MARK: UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return categories.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else { fatalError("Unable to dequeue a ImageCell") }
		
		// Get the name of the category from the dictionary keys
		let categoryName = categories[indexPath.row].key.rawValue
		cell.category = categoryName
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.emojiCategoryPickerViewController(self, didChangePageTo: indexPath.row)
	}
}
