//
//  UIImage+Extensions.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(view: UIView) {
		UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 2)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
		self.init(cgImage: image!.cgImage!, scale: UIScreen.main.scale, orientation: .up)
    }
	
	convenience init(document: CGPDFDocument, at size: CGSize? = nil) {
		let page = document.page(at: 1)!
		let scale: CGFloat
		
		let pageRect = page.getBoxRect(.mediaBox)
		
		// Get the scale amount needed to grow the image to the desized scale
		if let size = size {
			scale = size.width / pageRect.width
		} else {
			scale = 1
		}

		let scaledRect = pageRect.applying(CGAffineTransform(scaleX: scale, y: scale))
		
		UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0)
		let context = UIGraphicsGetCurrentContext()!
		
		context.clear(scaledRect)
		context.setFillColor(UIColor.clear.cgColor)
		context.fill(scaledRect)
		
		context.translateBy(x: 0.0, y: pageRect.size.height * scale)
		context.scaleBy(x: scale, y: -scale)
		
		context.drawPDFPage(page)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		self.init(cgImage: image!.cgImage!, scale: UIScreen.main.scale, orientation: .up)
	}
}
