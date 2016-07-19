//
//  UIViewController+Extensions.swift
//  EmojiStickers
//
//  Created by Raul Riera on 17/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension UIViewController {
	func removeChildViewControllers() {
		for child in self.childViewControllers {
			child.willMove(toParentViewController: nil)
			child.view.removeFromSuperview()
			child.removeFromParentViewController()
		}
	}
}
