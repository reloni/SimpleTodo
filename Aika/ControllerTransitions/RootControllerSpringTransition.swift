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
		class CATransitionEndDelegate: NSObject, CAAnimationDelegate {
			let didStop: (() -> Void)
			init(_ didStop: @escaping () -> Void) {
				self.didStop = didStop
			}
			func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
				didStop()
			}
		}
		
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
		let backgroundView: UIView?
		
		init(direction: Direction = .toTop, damping: CGFloat = 10, mass: CGFloat = 1, stiffness: CGFloat = 100, initialVelocity: CGFloat = 0, backgroundView: UIView? = nil) {
			self.direction = direction
			self.damping = damping
			self.mass = mass
			self.stiffness = stiffness
			self.initialVelocity = initialVelocity
			self.backgroundView = backgroundView
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
		let transitionWindow: UIWindow? = {
			guard let backgroundView = options.backgroundView else { return nil }
			
			let window = UIWindow(frame: UIScreen.main.bounds)
			backgroundView.frame = window.bounds
			window.rootViewController = UIViewController().configure { $0.view = backgroundView }
			window.makeKeyAndVisible()
			
			return window
		}()
		
		let animation = options.animation(for: controller)
		let delegate = SpringTransitionOptions.CATransitionEndDelegate { transitionWindow?.removeFromSuperview() }
		animation.delegate = delegate
		self.layer.add(animation, forKey: nil)
		self.rootViewController = controller
		self.makeKeyAndVisible()
	}
}
