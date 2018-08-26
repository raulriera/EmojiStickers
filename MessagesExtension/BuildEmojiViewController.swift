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
	func select(view: UIView) {
		guard let view = view as? EmojiView else { return }
		unselect()
		view.isSelected = true
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

    // MARK: IBOutlets

	@IBOutlet private weak var pickEmojiButton: UIButton! {
		didSet {
			let frame1 = UIImage(named: "Add Sticker-1")!
			let frame2 = UIImage(named: "Add Sticker-2")!
			let frame3 = UIImage(named: "Add Sticker-3")!
			let frame4 = UIImage(named: "Add Sticker-4")!

			pickEmojiButton.imageView?.animationImages = [frame1, frame2, frame3, frame4, frame3, frame2, frame1]
			pickEmojiButton.imageView?.animationDuration = 0.35
			pickEmojiButton.imageView?.animationRepeatCount = 1

			Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] timer in
				self?.pickEmojiButton.imageView?.startAnimating()

				if self == nil {
					timer.invalidate()
				}
			}
		}
	}
	
	@IBOutlet fileprivate weak var canvas: EmojiCanvas! {
		didSet {
			canvas.superview?.layer.borderWidth = 0.5
			canvas.superview?.layer.borderColor = UIColor.lightGray.cgColor
			canvas.superview?.layer.cornerRadius = 4.0

			let singleTap = createTapGestureRecognizer(targetView: canvas)
			let doubleTap = createDoubleTapGestureRecognizer(targetView: canvas)

			singleTap.require(toFail: doubleTap)

			createLongTapGestureRecognizer(targetView: canvas)
			createRotateGestureRecognizer(targetView: canvas)
			createPinchGestureRecognizer(targetView: canvas)
		}
	}

	// MARK: Overrides

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		// If the view size changed (rotation or iPad resizing) reset the offset
		// otherwise it is going to appear in an unexpected scroll position for the user
		resetOffsetCache()
	}

	override func willMove(toParentViewController parent: UIViewController?) {
		super.willMove(toParentViewController: parent)

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
	fileprivate var isViewInsideCanvas: Bool = true {
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
		addChildViewController(controller)
		
		controller.view.frame = view.bounds
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(controller.view)
		
		controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		controller.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
		controller.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
		
		controller.didMove(toParentViewController: self)
		
		controller.selectEmojiHandler = { [weak self] emoji, categoryIndex, selectionRect in
			self?.handleEmojiSelection(emoji: emoji, categoryIndex: categoryIndex, selectionRect: selectionRect)
		}

		// It's rude to show the user en empty page of emojis, if they have
		// no recent emojis, just go to the next page
		if RecentEmojiCache.load().emojis.isEmpty && lastUsedCategory == 0 {
			controller.changePage(to: 1, animated: false)
		} else {
			controller.changePage(to: lastUsedCategory, animated: false)
		}
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
	
	func createTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
		return gesture
	}
	
	func createDoubleTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		gesture.numberOfTapsRequired = 2
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
		return gesture
	}

	func createLongTapGestureRecognizer(targetView: UIView) {
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
		gesture.minimumPressDuration = 2.0
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
	}
	
	func createPanGestureRecognizer(targetView: UIView) {
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		gesture.delegate = self

		targetView.addGestureRecognizer(gesture)
	}
	
	func createPinchGestureRecognizer(targetView: UIView) {
		let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	func createRotateGestureRecognizer(targetView: UIView) {
		let gesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	// MARK: Gesture Handlers
	
	@objc func handleTap(recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) else { return }

		// Check the tapped view against all subviews
		// if it intersect with any, bring it to the front.
		for subview in canvas.subviews {
			if subview.frame.intersects(tappedView.frame) {
				if tappedView == subview {
					tappedView.superview?.bringSubview(toFront: tappedView)
					canvas.select(view: tappedView)
				} else {
					subview.superview?.bringSubview(toFront: subview)
					canvas.select(view: subview)
				}
				return
			}
		}
	}
	
	@objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) as? EmojiView else { return }

		if case .ended = recognizer.state {
			tappedView.isUserInteractionEnabled = false

			let direction: UIViewAnimationOptions = tappedView.isFlipped ? .transitionFlipFromLeft : .transitionFlipFromRight

			UIView.transition(with: tappedView, duration: 0.20, options: direction, animations: {
				tappedView.flipped()
			}, completion: { _ in
				tappedView.isUserInteractionEnabled = true
			})
		}
	}

	@objc func handleLongTap(recognizer: UILongPressGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let tappedView = canvas.hitTest(point, with: nil) as? EmojiView else { return }

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
	
	@objc func handlePan(recognizer: UIPanGestureRecognizer) {
		guard let view = recognizer.view else { return }

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
				}
			}
		}
	}
	
	@objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
		guard let lastView = canvas.subviews.last, let view = lastView as? EmojiView else { return }

		// Prevent the emoji from growing too large
		let maximumSize: CGSize = CGSize(width: 900, height: 900)
		
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
	
	@objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
		guard let view = canvas.subviews.last else { return }
		view.transform = view.transform.rotated(by: recognizer.rotation)
		recognizer.rotation = 0
	}
}
