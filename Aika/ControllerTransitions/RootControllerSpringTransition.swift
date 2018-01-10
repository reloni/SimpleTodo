//
//  RootControllerSpringTransition.swift
//  Aika
//
//  Created by Anton Efimenko on 10.01.2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
	struct SpringTransitionOptions {
		enum Direction {
			case toLeft
			case toRight
			case toTop
			case toBottom
		}
		
		let damping: CGFloat
		let mass: CGFloat
		let stiffness: CGFloat
		let initialVelocity: CGFloat
		let direction: Direction
		
		init(direction: Direction = .toTop, damping: CGFloat = 10, mass: CGFloat = 1, stiffness: CGFloat = 100, initialVelocity: CGFloat = 0) {
			self.direction = direction
			self.damping = damping
			self.mass = mass
			self.stiffness = stiffness
			self.initialVelocity = initialVelocity
		}
		
		func animation(for controller: UIViewController) -> CASpringAnimation {
			let animation: CASpringAnimation = {
				switch direction {
				case .toLeft, .toRight: return CASpringAnimation(keyPath: "position.x")
				case .toTop, .toBottom: return CASpringAnimation(keyPath: "position.y")
				}
			}()
			
			animation.damping = damping
			animation.mass = mass
			animation.stiffness = stiffness
			animation.initialVelocity = initialVelocity
			animation.duration = animation.settlingDuration
			
			switch direction {
			case .toLeft:
				animation.fromValue = controller.view.bounds.size.width * 2
				animation.toValue = controller.view.bounds.size.width / 2
			case .toRight:
				animation.fromValue = -controller.view.bounds.size.width
				animation.toValue = controller.view.bounds.size.width / 2
			case .toTop:
				animation.fromValue = controller.view.bounds.size.height * 2
				animation.toValue = controller.view.bounds.size.height / 2
			case .toBottom:
				animation.fromValue = -controller.view.bounds.size.height
				animation.toValue = controller.view.bounds.size.height / 2
			}
			
			return animation
		}
	}
	
	func setRootViewController(_ controller: UIViewController, withSpringOptions options: SpringTransitionOptions) {
		self.layer.add(options.animation(for: controller), forKey: nil)
		self.rootViewController = controller
		self.makeKeyAndVisible()
	}
}
