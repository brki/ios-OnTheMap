//
//  DetailCallout.swift
//  OnTheMap
//
//  Created by Brian on 05/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class DetailCallout: UIStackView {
	convenience init(labelTexts: [String]?) {
		var views = [UILabel]()
		if let texts = labelTexts {
			for text in texts {
				let label = UILabel()
				label.text = text
				views.append(label)
			}
		}
		self.init(arrangedSubviews: views)
		self.axis = .Vertical
	}
}