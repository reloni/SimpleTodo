//
//  Theme.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 14.01.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit
import Material

final class Theme {
	final class Images {
		static let checked = UIImage(named: "Checked")
		static let clock = UIImage(named: "Clock")
		static let delete = UIImage(named: "Delete")
		static let edit = UIImage(named: "Edit")
		static let trash = UIImage(named: "Trash")
	}
	
	final class Fonts {
		static let BaseNormal = UIFont.systemFont(ofSize: UIFont.systemFontSize)
		static let BaseBold = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
		static let BaseItalic = UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)
		static let Main = Fonts.BaseNormal.new(sizeModifier: 4)
		static let Accesory = Fonts.BaseItalic.new(sizeModifier: 1)
	}
	
	final class Colors {
		static let backgroundLightGray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
	}
}
