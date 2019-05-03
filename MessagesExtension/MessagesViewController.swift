//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Raúl Riera on 18/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

final class MessagesViewController: MSMessagesAppViewController {
	var state: State = .browsing {
		didSet {
			if case .browsing = state {
				requestPresentationStyle(.compact)
				presentViewController(for: .compact)
			} else {
				requestPresentationStyle(.expanded)
				presentViewController(for: .expanded)
			}
		}
	}

	enum State {
		case browsing
		case creating
	}

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
		// Present the view controller for the appropriate presentation style.
		presentViewController(for: presentationStyle)
		
		let key = "UpdatedToTwitterEmoji12.0"
		// Run this code only once per "Emoji assets update"
		//if !UserDefaults.standard.bool(forKey: key) {
			ImageCache.cache.clear()
			SkinToneCache.load().clear()
			EmojiCategoryOffsetCache.load().clear()
			//RecentEmojiCache.load().clear()

			UserDefaults.standard.set(true, forKey: key)
		//}
    }
    
    // MARK: MSMessagesAppViewController

	override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
		super.didTransition(to: presentationStyle)

		// If the state is "creating an emoji" but the presentation is "compact"
		// then switch to "browsing emojis" because the creating state doesn't fit
		if case .creating = state, presentationStyle == .compact {
			state = .browsing
		}
	}
    
    // MARK: Private
    
    private func presentViewController(for presentationStyle: MSMessagesAppPresentationStyle) {
        // Determine the controller to present.
        let controller: UIViewController
        if case .browsing = state {
            // Show a list of previously created emojis.
            controller = instantiateStickersController()
        } else {
            controller = instantiateBuildEmojiController()
        }
        
        // Remove any existing child controllers.
		for child in children {
			UIView.animate(withDuration: 0.25, animations: { 
				child.view.alpha = 0

			}, completion: { _ in
				child.willMove(toParent: nil)
				child.view.removeFromSuperview()
				child.removeFromParent()
			})
        }
        
        // Embed the new controller.
		addChild(controller)

		controller.view.alpha = 0
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
		
		NSLayoutConstraint.activate([
			controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])

		controller.didMove(toParent: self)

		UIView.animate(withDuration: 0.25) {
			controller.view.alpha = 1
		}
    }
    
    private func instantiateBuildEmojiController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildEmojiViewController.storyboardIdentifier) as? BuildEmojiViewController else { fatalError("Unable to instantiate a BuildEmojiViewController from the storyboard") }
        
        controller.delegate = self
        
        return controller
    }
    
    private func instantiateStickersController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: StickersViewController.storyboardIdentifier) as? StickersViewController else { fatalError("Unable to instantiate an StickersViewController from the storyboard") }
        
        controller.delegate = self
        
        return controller
    }
}

// MARK: BuildEmojiViewControllerDelegate

extension MessagesViewController: BuildEmojiViewControllerDelegate {
    func buildEmojiViewController(_ controller: BuildEmojiViewController, didFinish emoji: EmojiSticker) {
		state = .browsing
    }
}

// MARK: EmojisViewControllerDelegate

extension MessagesViewController: StickersViewControllerDelegate {
    func stickersViewControllerDidSelectCreate(_ controller: StickersViewController) {
		state = .creating
    }
}
