//
//  EmojiCategoriesViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 02/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

final class EmojiCategoriesViewController: UIPageViewController {
	typealias SelectEmojiHandler = (Emoji, Int, CGRect) -> ()
	
	@IBOutlet private var searchBarContainer: UIVisualEffectView!
	@IBOutlet private var searchBar: UISearchBar!
	
	static let storyboardIdentifier = "EmojiCategoriesViewController"
	var selectEmojiHandler: SelectEmojiHandler?

	private let emojiDictionary = EmojiDictionary()
	private weak var categoryPickerViewController: EmojiCategoryPickerViewController?
	private var currentIndex: Int {
		guard let visibleViewController = viewControllers?.first as? EmojiCategoryViewController,
			let category = visibleViewController.category,
			let index = emojiDictionary.categories.firstIndex(where: { $0 == category }) else { return 0 }
		
		return index
	}
		
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		
		view.backgroundColor = UIColor.groupTableViewBackground

		presentCartegorySearchBar()
		presentCategoryPickerController()
	}
	
	func changePage(to newPage: Int, animated: Bool = true) {
		clearSearchBar()
		let animationDirection: UIPageViewController.NavigationDirection
		
		if newPage < currentIndex {
			animationDirection = .reverse
		} else {
			animationDirection = .forward
		}
		
		// Skip to the selected section
		let viewController = newEmojiCategoryViewController(emojiDictionary.categories[newPage])
		setViewControllers([viewController],
		                   direction: animationDirection,
		                   animated: animated,
		                   completion: nil)
		
		categoryPickerViewController?.selectedCategory = currentIndex
	}
	
	// MARK: Private
	
	private func presentCartegorySearchBar() {
		searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(searchBarContainer)
		
		NSLayoutConstraint.activate([
			searchBarContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
			searchBarContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
			searchBarContainer.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
			searchBarContainer.heightAnchor.constraint(equalToConstant: 56)
		])
		
		searchBar.delegate = self
	}
	
	private func presentCategoryPickerController() {
		categoryPickerViewController = instantiateCategoryPickerViewController()
		
		guard let categoryPickerViewController = categoryPickerViewController else { return }
		
		// Embed the new controller.
		addChild(categoryPickerViewController)
		
		categoryPickerViewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(categoryPickerViewController.view)
		
		NSLayoutConstraint.activate([
			categoryPickerViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
			categoryPickerViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
			categoryPickerViewController.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor),
			categoryPickerViewController.view.heightAnchor.constraint(equalToConstant: 34)
		])
		
		categoryPickerViewController.didMove(toParent: self)
		
		categoryPickerViewController.selectedCategory = currentIndex
	}
	
	private func instantiateCategoryPickerViewController() -> EmojiCategoryPickerViewController {
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoryPickerViewController.storyboardIdentifier) as? EmojiCategoryPickerViewController else { fatalError("Unable to instantiate a EmojiCategoryPickerViewController from the storyboard") }
		
		controller.categories = emojiDictionary.categories
		controller.delegate = self
		
		return controller
	}
	
	private func newEmojiCategoryViewController(_ category: EmojiDictionary.Category) -> EmojiCategoryViewController {
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoryViewController.storyboardIdentifier) as? EmojiCategoryViewController else { fatalError("Unable to instantiate a EmojiCategoryViewController from the storyboard") }
		
		controller.category = category
		controller.delegate = self
		
		// top = for the search bar and 34 for the category picker
		controller.collectionView?.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 34, right: 0)
		controller.collectionView?.scrollIndicatorInsets = controller.collectionView!.contentInset
		
		return controller
	}
}

extension EmojiCategoriesViewController: UISearchBarDelegate {
	func clearSearchBar() {
		searchBar.text = nil
		searchBar(searchBar, textDidChange: "")
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let emojiViewController = viewControllers?.first as? EmojiCategoryViewController else { return }
		
		if searchText.isEmpty == false {
			let filteredEmojis = emojiDictionary.search(query: searchText)
			emojiViewController.category = EmojiDictionary.Category(key: emojiViewController.category.key, value: filteredEmojis)
		} else {
			emojiViewController.category = emojiDictionary.categories.first { $0.key == emojiViewController.category.key }
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
}

extension EmojiCategoriesViewController: EmojiCategoryViewControllerDelegate {
	func emojiCategoryViewController(_ controller: EmojiCategoryViewController, didSelect emoji: Emoji, at rect: CGRect) {
		// Update the recently used emoji cache
		var recentEmojis = RecentEmojiCache.load()

		recentEmojis.append(emoji)
		selectEmojiHandler?(emoji, currentIndex, rect)
	}
}

// MARK: UIPageViewControllerDelegate

extension EmojiCategoriesViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed else { return }
		categoryPickerViewController?.selectedCategory = currentIndex
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		clearSearchBar()
	}
}

// MARK: UIPageViewControllerDataSource

extension EmojiCategoriesViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let previousIndex = currentIndex - 1
		
		guard previousIndex >= 0 else {
			return nil
		}
		
		guard emojiDictionary.categories.count > previousIndex else {
			return nil
		}
		
		return newEmojiCategoryViewController(emojiDictionary.categories[previousIndex])
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		let nextIndex = currentIndex + 1
		let stationsCount = emojiDictionary.categories.count
		
		guard stationsCount != nextIndex else {
			return nil
		}
		
		guard stationsCount > nextIndex else {
			return nil
		}
		
		return newEmojiCategoryViewController(emojiDictionary.categories[nextIndex])
	}
}

// MARK: EmojiCategoryPickerViewControllerDelegate

extension EmojiCategoriesViewController: EmojiCategoryPickerViewControllerDelegate {
	func emojiCategoryPickerViewController(_ controller: EmojiCategoryPickerViewController, didChangePageTo page: Int) {
		guard page != currentIndex else { return }
		changePage(to: page)
	}
}
