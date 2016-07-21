//
//  SkinToneViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class SkinToneViewController: UIViewController {
	typealias onSelectedHandler = (String) -> ()
	
	@IBOutlet private var skinToneButtons: [UIButton]! {
		didSet {
			// Prevent the buttons from being horribly streched
			// I wish Storyboards would allow me to do this
			_ = skinToneButtons.map {
				$0.imageView?.contentMode = .scaleAspectFit
			}
		}
	}
	
	private let skinTones = [ "", "🏻", "🏼", "🏽", "🏾", "🏿" ]
	private let skinToneHistory = SkinToneCache.load()
	var selectedSkinTone: String = "" {
		didSet {
			skinToneHistory.save(tone: selectedSkinTone)
			onSelected?(selectedSkinTone)
		}
	}
	var onSelected: onSelectedHandler? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		preferredContentSize = CGSize(width: 300, height: 64)
		
		for (index, tone) in skinTones.enumerated() {
			if tone == skinToneHistory.tone {
				skinToneButtons[index].transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
				return
			}
		}
	}
	
	@IBAction func didTapSkinButton(sender: UIButton) {
		for (index, button) in skinToneButtons.enumerated() {
			if button == sender {
				selectedSkinTone = skinTones[index]
				return
			}
		}
	}
}
