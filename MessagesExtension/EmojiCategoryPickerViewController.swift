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

class EmojiCategoryPickerViewController: UICollectionViewController {
	
	// MARK: Properties
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateRoundedBar(for: view.bounds.size)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		updateRoundedBar(for: size)
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
	
	// MARK: Private
	
	private func updateRoundedBar(for size: CGSize) {
		let layerName = "roundedBar"
		
		// Remove previous versions of this layer
		for sublayer in view.layer.sublayers ?? [] where sublayer.name == layerName {
			sublayer.removeFromSuperlayer()
		}
		
		let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6, height: 6))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		view.layer.mask = mask
		
		let shape = CAShapeLayer()
		shape.path = mask.path
		shape.fillColor = UIColor.clear.cgColor
		shape.strokeColor = UIColor.systemGray3.cgColor
		shape.borderWidth = 0.5
		shape.name = "roundedBar"
		
		view.layer.addSublayer(shape)
	}
}
