//
//  Theme.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 14.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class Theme {
	final class Images {
		static let checked = UIImage(named: "Checked")
		static let clock = UIImage(named: "Clock")
		static let delete = UIImage(named: "Delete")
		static let edit = UIImage(named: "Edit")
		static let trash = UIImage(named: "Trash")
	}
	
	final class Fonts {
		static let baseNormal = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		static let baseBold = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		static let baseItalic = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
		static let main = Fonts.baseNormal.new(sizeModifier: 4)
		static let textFieldTitle = Fonts.baseNormal.new(sizeModifier: 2)
		static let accesory = Fonts.baseItalic.new(sizeModifier: 1)
	}
	
	final class Colors {
		static let backgroundLightGray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
		static let appleBlue = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)
		static let lightGray = UIColor.lightGray
		static let white = UIColor.white
	}
}
