//
//  PLInteractiveTransitionGesc.swift
//  Play
//
//  Created by Tbxark on 2018/7/4.
//  Copyright © 2018 TBXark. All rights reserved.
//

import UIKit

public enum ActionKind {
    case dismiss(completion: (() -> Void)?)
    case pop
}

public enum Direction {
    case vertical
    case horizontal
}

public class Interactor: UIPercentDrivenInteractiveTransition {
    
    
    private let actionKind: ActionKind
    public private(set) var direction: Direction? = .vertical
    public private(set) var viewController : UIViewController
    public private(set) var swipeBackGesture: UIPanGestureRecognizer?
    public private(set) var shouldCompleteTransition = false
    public private(set) var transitionInProgress = false
    
    public init(attachTo viewController : UIViewController, actionKind: ActionKind) {
        self.viewController = viewController
        self.actionKind = actionKind
        super.init()
        let swipeBackGesture = UIPanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        self.swipeBackGesture = swipeBackGesture
        viewController.view.addGestureRecognizer(swipeBackGesture)
    }
    
    @objc private func handleBackGesture(_ gesture : UIPanGestureRecognizer) {
        let viewTranslation = gesture.translation(in: viewController.view)

        let xProgress = viewTranslation.x / self.viewController.view.frame.width
        let yProgress = viewTranslation.y / self.viewController.view.frame.height
        
        switch gesture.state {
        case .began:
            transitionInProgress = true
            direction = xProgress > yProgress ? Direction.horizontal : Direction.vertical
            switch actionKind {
            case .dismiss(let completion):
                viewController.dismiss(animated: true, completion: completion)
            case .pop:
                if let nav = viewController as? UINavigationController {
                    nav.popViewController(animated: true)
                } else {
                    viewController.navigationController?.popViewController(animated: true)
                }
            }
        case .changed:
            let currentDirection = direction ?? Direction.horizontal
            switch currentDirection {
            case .horizontal:
                shouldCompleteTransition = xProgress > 0.5
                update(xProgress)
            case .vertical:
                shouldCompleteTransition = yProgress > 0.5
                update(yProgress)
            }
            
        case .cancelled:
            transitionInProgress = false
            cancel()
        case .ended:
            transitionInProgress = false
            shouldCompleteTransition ? finish() : cancel()
        default:
            return
        }
    }
    
}




public class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let direction: Direction
    private let duration: TimeInterval
    
    public init(direction: Direction, duration: TimeInterval) {
        self.direction = direction
        self.duration = duration
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let screenBounds = UIScreen.main.bounds
        
        let finalPosition = direction == .vertical ? CGPoint(x: 0, y: screenBounds.height) : CGPoint(x:  screenBounds.width, y: 0)
        let finalFrame = CGRect(origin: finalPosition, size: screenBounds.size)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromVC.view.frame = finalFrame
        }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
    }
}

