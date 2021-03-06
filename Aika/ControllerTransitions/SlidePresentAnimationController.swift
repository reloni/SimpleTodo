//
//  SlidePresentAnimationController.swift
//  SimpleToDo
//
//  Created by Anton Efimenko on 29.04.17.
//  Copyright © 2017 Anton Efimenko. All rights reserved.
//

import UIKit

final class TransitionDelegate : NSObject, UIViewControllerTransitioningDelegate {
	let presentationController: UIViewControllerAnimatedTransitioning?
	let dismissalController: UIViewControllerAnimatedTransitioning?
	
	init(presentationController: UIViewControllerAnimatedTransitioning? = nil, dismissalController: UIViewControllerAnimatedTransitioning? = nil) {
		self.presentationController = presentationController
		self.dismissalController = dismissalController
	}
	
	func animationController(forPresented presented: UIViewController,
	                         presenting: UIViewController,
	                         source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return presentationController
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissalController
	}
}

final class SlidePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	enum Mode {
		case toLeft, toRight, toBottom, toTop
	}
	
	let duration: TimeInterval
	let mode: Mode
	let damping: CGFloat
	let velocity: CGFloat
	
	init(duration: TimeInterval = 0.5, mode: Mode = .toLeft, damping: CGFloat = 0.7, velocity: CGFloat = 0.7) {
		self.duration = duration
		self.mode = mode
		self.damping = damping
		self.velocity = velocity
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let finalFrameForVC = transitionContext.finalFrame(for: toViewController)

		toViewController.view.frame = {
			switch mode {
			case .toRight: return finalFrameForVC.offsetBy(dx: -UIScreen.main.bounds.size.width, dy: 0)
			case .toLeft: return finalFrameForVC.offsetBy(dx: UIScreen.main.bounds.size.width, dy: 0)
			case .toBottom: return finalFrameForVC.offsetBy(dx: 0, dy: -UIScreen.main.bounds.size.height)
			case .toTop: return finalFrameForVC.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
			}
		}()
		
		transitionContext.containerView.addSubview(toViewController.view)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext),
		               delay: 0.0,
		               usingSpringWithDamping: damping,
		               initialSpringVelocity: velocity,
		               options: .curveEaseOut,
		               animations: { toViewController.view.frame = finalFrameForVC },
		               completion: { _ in transitionContext.completeTransition(true) })
	}
}

final class SlideDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	enum Mode {
		case toLeft, toRight, toBottom, toTop
	}
	
	let duration: TimeInterval
	let mode: Mode
	
	init(duration: TimeInterval = 0.5, mode: Mode = .toLeft) {
		self.duration = duration
		self.mode = mode
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
		let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
		
		toViewController.view.frame = finalFrameForVC
		fromViewController.view.frame = finalFrameForVC
		
		let moveToFrame: CGRect = {
			switch mode {
			case .toRight: return finalFrameForVC.offsetBy(dx: UIScreen.main.bounds.size.width, dy: 0)
			case .toLeft: return finalFrameForVC.offsetBy(dx: -UIScreen.main.bounds.size.width, dy: 0)
			case .toBottom: return finalFrameForVC.offsetBy(dx: 0, dy: UIScreen.main.bounds.size.height)
			case .toTop: return finalFrameForVC.offsetBy(dx: 0, dy: -UIScreen.main.bounds.size.height)
			}
		}()

		transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.containerView.sendSubviewToBack(toViewController.view)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext),
		               delay: 0.0,
		               options: .curveEaseOut,
		               animations: { fromViewController.view.frame = moveToFrame },
		               completion: { _ in transitionContext.completeTransition(true) })
	}
}
