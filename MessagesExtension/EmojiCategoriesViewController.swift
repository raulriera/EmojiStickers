//
//  EmojiCategoriesViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 02/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class EmojiCategoriesViewController: UIPageViewController {
	typealias SelectEmojiHandler = (String, Int, CGRect) -> ()
	
	// MARK: Properties
	
	static let storyboardIdentifier = "EmojiCategoriesViewController"
	var selectEmojiHandler: SelectEmojiHandler?

	fileprivate weak var categoryPickerViewController: EmojiCategoryPickerViewController?
	fileprivate let emojis = EmojiDictionary()
	fileprivate var currentIndex: Int {
		guard let visibleViewController = viewControllers?.first as? EmojiCategoryViewController,
			let category = visibleViewController.category,
			let index = emojis.categories.index(where: { $0 == category }) else { return 0 }
		
		return index
	}
		
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		
		view.backgroundColor = UIColor.groupTableViewBackground

		presentCategoryPickerController()
	}
	
	func changePage(to newPage: Int, animated: Bool = true) {
		let animationDirection: UIPageViewControllerNavigationDirection
		
		if newPage < currentIndex {
			animationDirection = .reverse
		} else {
			animationDirection = .forward
		}
		
		// Skip to the selected section
		let viewController = newEmojiCategoryViewController(emojis.categories[newPage])
		setViewControllers([viewController],
		                   direction: animationDirection,
		                   animated: animated,
		                   completion: nil)
		
		categoryPickerViewController?.selectedCategory = currentIndex
	}
	
	// MARK: Private
	
	fileprivate func presentCategoryPickerController() {
		categoryPickerViewController = instantiateCategoryPickerViewController()
		
		guard let categoryPickerViewController = categoryPickerViewController else { return }
		
		// Embed the new controller.
		addChildViewController(categoryPickerViewController)
		
		categoryPickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(categoryPickerViewController.view)
		
		categoryPickerViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		categoryPickerViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		categoryPickerViewController.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
		categoryPickerViewController.view.heightAnchor.constraint(equalToConstant: 34).isActive = true
		
		categoryPickerViewController.didMove(toParentViewController: self)
		
		categoryPickerViewController.selectedCategory = currentIndex
	}
	
	fileprivate func instantiateCategoryPickerViewController() -> EmojiCategoryPickerViewController {
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoryPickerViewController.storyboardIdentifier) as? EmojiCategoryPickerViewController else { fatalError("Unable to instantiate a EmojiCategoryPickerViewController from the storyboard") }
		
		controller.categories = emojis.categories
		controller.delegate = self
		
		return controller
	}
	
	fileprivate func newEmojiCategoryViewController(_ category: EmojiDictionary.Category) -> EmojiCategoryViewController {
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoryViewController.storyboardIdentifier) as? EmojiCategoryViewController else { fatalError("Unable to instantiate a EmojiCategoryViewController from the storyboard") }
		
		controller.category = category
		controller.delegate = self
		
		controller.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
		controller.collectionView?.scrollIndicatorInsets = controller.collectionView!.contentInset
		
		return controller
	}
}

extension EmojiCategoriesViewController: EmojiCategoryViewControllerDelegate {
	func emojiCategoryViewController(_ controller: EmojiCategoryViewController, didSelect emoji: String, at rect: CGRect) {
		// Update the recently used emoji cache
		var recentEmojis = RecentEmojiCache.load()
		// We need to use the unmodified version while keeping the gender sign
		recentEmojis.append(emoji.emojiUnmodifiedPreservingGenderSign)

		selectEmojiHandler?(emoji, currentIndex, rect)
	}
}

// MARK: UIPageViewControllerDelegate

extension EmojiCategoriesViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		
		guard completed else { return }
		categoryPickerViewController?.selectedCategory = currentIndex
	}
}

// MARK: UIPageViewControllerDataSource

extension EmojiCategoriesViewController: UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let previousIndex = currentIndex - 1
		
		guard previousIndex >= 0 else {
			return nil
		}
		
		guard emojis.categories.count > previousIndex else {
			return nil
		}
		
		return newEmojiCategoryViewController(emojis.categories[previousIndex])
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		let nextIndex = currentIndex + 1
		let stationsCount = emojis.categories.count
		
		guard stationsCount != nextIndex else {
			return nil
		}
		
		guard stationsCount > nextIndex else {
			return nil
		}
		
		return newEmojiCategoryViewController(emojis.categories[nextIndex])
	}
}

// MARK: EmojiCategoryPickerViewControllerDelegate

extension EmojiCategoriesViewController: EmojiCategoryPickerViewControllerDelegate {
	func emojiCategoryPickerViewController(_ controller: EmojiCategoryPickerViewController, didChangePageTo page: Int) {
		guard page != currentIndex else { return }

		changePage(to: page)
	}
}
