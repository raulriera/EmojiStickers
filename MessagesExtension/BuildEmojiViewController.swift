//
//  BuildEmojiViewController.swift
//  EmojiStickers
//
//  Created by Raúl Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

/**
A delegate protocol for the `BuildEmojiViewController` class.
*/
protocol BuildEmojiViewControllerDelegate: class {
	/// Called when the user taps to finished the `Emoji` in the `BuildEmojiViewController`.
	func buildEmojiViewController(_ controller: BuildEmojiViewController, didFinish emoji: EmojiSticker)
}

final class EmojiCanvas: UIView {
	var isEmpty: Bool {
		return subviews.isEmpty
	}
	var selectedView: EmojiView? {
		return subviews.compactMap { $0 as? EmojiView }.first { $0.isSelected }
	}
	var onSelection: ((EmojiView) -> Void)?
	
	func select(view: UIView) {
		guard let view = view as? EmojiView else { return }
		unselect()
		view.isSelected = true
		onSelection?(view)
	}

	func selectLastView() {
		guard let lastView = subviews.last else { return }
		select(view: lastView)
	}

	func unselect() {
		guard let emojiViews = subviews as? [EmojiView] else { return }

		for subview in emojiViews {
			subview.isSelected = false
		}
	}
}

final class BuildEmojiViewController: UIViewController {
	@IBOutlet private weak var pickEmojiButton: UIButton!
	@IBOutlet private weak var toggleLockButton: UIButton!
	@IBOutlet private weak var saveButton: UIButton!
	@IBOutlet private weak var canvas: EmojiCanvas! {
		didSet {
			canvas.superview?.layer.borderWidth = 0.5
			canvas.superview?.layer.borderColor = UIColor.systemGray3.cgColor
			canvas.superview?.layer.cornerRadius = 12.0

			let singleTap = createTapGestureRecognizer(targetView: canvas)
			let doubleTap = createDoubleTapGestureRecognizer(targetView: canvas)

			singleTap.require(toFail: doubleTap)

			createLongTapGestureRecognizer(targetView: canvas)
			createRotateGestureRecognizer(targetView: canvas)
			createPinchGestureRecognizer(targetView: canvas)
		}
	}

	// MARK: Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		canvas.onSelection = { [weak self] selectedView in
			self?.toggleLockEmoji(selectedView: selectedView)
			
			self?.toggleLockButton.isEnabled = true
			self?.saveButton.isEnabled = true
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		// If the view size changed (rotation or iPad resizing) reset the offset
		// otherwise it is going to appear in an unexpected scroll position for the user
		resetOffsetCache()
	}

	override func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)

		// Are we closing this View Controller?
		if parent == nil {
			removeChildViewControllers()
		} else {
			// Reset the offset to zero, because we don't want any
			// unexpected "jumps" to scrolls positions. Given that the app
			// shut down but the position was still saved.
			resetOffsetCache()
		}
	}
	
    // MARK: Properties
    
    static let storyboardIdentifier = "BuildEmojiViewController"
    weak var delegate: BuildEmojiViewControllerDelegate?
	private var lastUsedCategory: Int = 0
	private var isViewInsideCanvas: Bool = true {
		didSet {
			if oldValue != isViewInsideCanvas {
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			}
		}
	}
		
	// MARK: IBActions
	
	@IBAction func didTapPickEmoji(_ sender: UIButton) {
		guard let controller = instantiateEmojiCategoriesController() as? EmojiCategoriesViewController else { return }

		// Remove any existing child controllers.
		removeChildViewControllers()
		
		// Embed the new controller.
		addChild(controller)
		
		controller.view.frame = view.bounds
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(controller.view)
		
		NSLayoutConstraint.activate([
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			controller.view.topAnchor.constraint(equalTo: view.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
		
		controller.didMove(toParent: self)
		
		controller.selectEmojiHandler = { [weak self] emoji, categoryIndex, selectionRect in
			self?.handleEmojiSelection(emoji: emoji, categoryIndex: categoryIndex, selectionRect: selectionRect)
		}
		controller.dismissHandler = { [weak self] in
			self?.removeChildViewControllers()
		}

		// It's rude to show the user en empty page of emojis, if they have
		// no recent emojis, just go to the next page
		if RecentEmojiCache.load().emojis.isEmpty && lastUsedCategory == 0 {
			controller.changePage(to: 1, animated: false)
		} else {
			controller.changePage(to: lastUsedCategory, animated: false)
		}
	}
	
	@IBAction func didTapToggleLock(_ sender: UIButton) {
		guard let selectedView = canvas.selectedView else { return }
		selectedView.isLocked = !selectedView.isLocked
		toggleLockEmoji(selectedView: selectedView)
	}

	@IBAction func didTapSave(_ sender: UIButton) {
		guard canvas.subviews.isEmpty == false else { return }
		canvas.unselect()

		let image = UIImage(view: canvas)
		let emoji = EmojiSticker(uuid: UUID(), image: image)
		
		// Append this sticker to the history
		var history = EmojiHistory.load()
		history.append(emoji)
		history.save()
		
		// Use a placeholder sticker while we fetch the real one from the cache.
		let cache = StickerCache.cache
		
		// Fetch the sticker for the emoji from the cache.
		cache.sticker(for: emoji) { sticker in
			OperationQueue.main.addOperation {
				// If the cell is still showing the same emoji, update its sticker view.
				self.delegate?.buildEmojiViewController(self, didFinish: emoji)
			}
		}
	}
	
	// MARK: Private
	
	private func toggleLockEmoji(selectedView: EmojiView) {
		toggleLockButton.setImage(UIImage(named: selectedView.isLocked ? "Unlock Sticker" : "Lock Sticker"), for: .normal)
	}
	
	private func instantiateEmojiCategoriesController() -> UIViewController {
		// Instantiate a `EmojiCategoriesViewController` and present it.
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoriesViewController.storyboardIdentifier) as? EmojiCategoriesViewController else { fatalError("Unable to instantiate a EmojiCategoriesViewController from the storyboard") }
		
		return controller
	}

	private func handleEmojiSelection(emoji: Emoji, categoryIndex: Int, selectionRect: CGRect) -> () {
		lastUsedCategory = categoryIndex
		let emojiHexcode = emoji.applying(skinTone: SkinToneCache.load().tone)
		let emojiView = EmojiView(hexcode: emojiHexcode)
		
		// Convert the point to the canvas coordinates, while
		// also inseting the point because it appears it won't take into
		// consideration the navigation bar
		emojiView.frame = emojiView.convert(selectionRect, to: canvas)
		emojiView.frame.origin = emojiView.frame.origin.insetBy(dx: 0, dy: view.frame.origin.y)
		canvas.addSubview(emojiView)

		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
			emojiView.center = self.canvas.convert(self.canvas.center, to: self.canvas.superview)
			}, completion: { _ in

				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
						emojiView.bounds.size = emojiView.defaultSize
				}, completion: nil)
		})

		createPanGestureRecognizer(targetView: emojiView)

		canvas.select(view: emojiView)

		// Remove any existing child controllers.
		removeChildViewControllers()
	}

	private func resetOffsetCache() {
		EmojiCategoryOffsetCache.load().save(offset: .zero)
	}
}

// MARK: UIGestureRecognizerDelegate

extension BuildEmojiViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

		if gestureRecognizer is UILongPressGestureRecognizer ||
			gestureRecognizer is UITapGestureRecognizer ||
			gestureRecognizer is UIPanGestureRecognizer {
			return false
		}

		return true
	}
	
	// MARK: Gesture Helpers
	
	private func createTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
		return gesture
	}
	
	private func createDoubleTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		gesture.numberOfTapsRequired = 2
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
		return gesture
	}

	private func createLongTapGestureRecognizer(targetView: UIView) {
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
		gesture.minimumPressDuration = 2.0
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
	}
	
	private func createPanGestureRecognizer(targetView: UIView) {
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
	}
	
	private func createPinchGestureRecognizer(targetView: UIView) {
		let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	private func createRotateGestureRecognizer(targetView: UIView) {
		let gesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	// MARK: Gesture Handlers
	
	@objc private func handleTap(recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) else { return }
		
		// Check the tapped view against all subviews
		// if it intersect with any, bring it to the front.
		for subview in canvas.subviews {
			if subview.frame.intersects(tappedView.frame) {
				if tappedView == subview {
					tappedView.superview?.bringSubviewToFront(tappedView)
					canvas.select(view: tappedView)
				} else {
					subview.superview?.bringSubviewToFront(subview)
					canvas.select(view: subview)
				}
				return
			}
		}
	}
	
	@objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) as? EmojiView, !tappedView.isLocked else { return }

		if case .ended = recognizer.state {
			tappedView.isUserInteractionEnabled = false

			let direction: UIView.AnimationOptions = tappedView.isFlipped ? .transitionFlipFromLeft : .transitionFlipFromRight

			UIView.transition(with: tappedView, duration: 0.20, options: direction, animations: {
				tappedView.flipped()
			}, completion: { _ in
				tappedView.isUserInteractionEnabled = true
			})
		}
	}

	@objc private func handleLongTap(recognizer: UILongPressGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) as? EmojiView, !tappedView.isLocked else { return }

		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
			tappedView.transform = .identity
			tappedView.bounds.size = tappedView.defaultSize

			if tappedView.isFlipped {
				tappedView.flipped()
			}

			}, completion: { _ in
				tappedView.setNeedsImageUpdate()
		})
	}
	
	@objc private func handlePan(recognizer: UIPanGestureRecognizer) {
		guard let view = recognizer.view as? EmojiView, !view.isLocked else { return }

		let translation = recognizer.translation(in: self.view)
		
		view.center = CGPoint(x:view.center.x + translation.x,
							  y:view.center.y + translation.y)
		
		recognizer.setTranslation(.zero, in: self.view)
				
		isViewInsideCanvas = canvas.bounds.contains(view.center)
		
		switch recognizer.state {
		case .changed:
			view.alpha = isViewInsideCanvas ? 1.0 : 0.5
		default:
			if !isViewInsideCanvas {
				view.isUserInteractionEnabled = false
				
				UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseIn, animations: {
					view.transform = view.transform.scaledBy(x: 0.1, y: 0.1)
					view.alpha = 0
				}) { _ in
					view.removeFromSuperview()
					self.canvas.selectLastView()
					self.toggleLockButton.isEnabled = self.canvas?.isEmpty == false
					self.saveButton.isEnabled = self.canvas?.isEmpty == false
				}
			}
		}
	}
	
	@objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
		guard let lastView = canvas.subviews.last, let view = lastView as? EmojiView, !view.isLocked else { return }

		// Prevent the emoji from growing too large
		let maximumSize: CGSize = CGSize(width: 1100, height: 1100)
		
		// If the view grows too large, the app will crash
		guard view.bounds.size.height <= maximumSize.height else {
			view.bounds.size = maximumSize
			return
		}
		
		view.bounds = view.bounds.applying(CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale))
		
		recognizer.scale = 1
		
		// When the use stops pinching the view, render it again
		// so it always looks crispy
		switch recognizer.state {
		case .ended, .cancelled:
			view.setNeedsImageUpdate()
		default: break;
		}
	}
	
	@objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
		guard let view = canvas.subviews.last as? EmojiView, !view.isLocked else { return }
		view.transform = view.transform.rotated(by: recognizer.rotation)
		recognizer.rotation = 0
	}
}
