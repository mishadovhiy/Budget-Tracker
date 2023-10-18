//
//  AnimatedImageManagerNav.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 11.10.2023.
//

import UIKit

final class AnimatedTransitioningManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    var beginTransactionPressedView:UIView?
    var canDivideFrame:Bool = true
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            fatalError()
        }
        if let homeVC = fromVC as? ViewController ?? toVC as? ViewController,
           let transactionVC = toVC as? TransitionVC ?? fromVC as? TransitionVC {
            self.transactionPerform(homeVC: homeVC, transactionVC: transactionVC, using: transitionContext)
        } else if let homeVC = fromVC as? HistoryVC ?? toVC as? HistoryVC,
                  let transactionVC = toVC as? TransitionVC ?? fromVC as? TransitionVC {
            self.transactionPerform(homeVC: homeVC, transactionVC: transactionVC, using: transitionContext)

        } else if let homeVC = fromVC as? RemindersVC ?? toVC as? RemindersVC,
                  let transactionVC = toVC as? TransitionVC ?? fromVC as? TransitionVC {
            self.transactionPerform(homeVC: homeVC, transactionVC: transactionVC, using: transitionContext)
        } else {
            fatalError()
        }
        
    }
    
}


//movieVC - ImgVC
private extension AnimatedTransitioningManager {
    struct TransitionViews {
        let animatedView:UIView?
        let primatyView:UIView?
        var animatedFrame:CGRect? = nil
        var animatedRegView:UIView? = nil
        var viewFrame:CGRect? = nil
    }
    
    func transactionPerform(homeVC:ViewController, transactionVC:TransitionVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? ViewController) != nil
        let plusButton = homeVC.addTransitionButton
        presentImageVC(.init(animatedView: show ? transactionVC.valueLabel : homeVC.addTransitionButton, primatyView: show ? transactionVC.view : homeVC.view), from: .init(animatedView: show ? plusButton : plusButton, primatyView: show ? homeVC.view : transactionVC.view), with: transitionContext, isPresenting: show)
    }
    
    func transactionPerform(homeVC:RemindersVC, transactionVC:TransitionVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? RemindersVC) != nil
        let plusButton = homeVC.addTransactionButton
        presentImageVC(.init(animatedView: show ? transactionVC.valueLabel : plusButton, primatyView: show ? transactionVC.view : homeVC.view), from: .init(animatedView: show ? transactionVC.valueLabel : plusButton, primatyView: show ? homeVC.view : transactionVC.view), with: transitionContext, isPresenting: show)
    }
    
    func transactionPerform(homeVC:HistoryVC, transactionVC:TransitionVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? HistoryVC) != nil
        let plusButton = homeVC.addTransButton
        presentImageVC(.init(animatedView: show ? transactionVC.valueLabel : homeVC.addTransButton, primatyView: show ? transactionVC.view : homeVC.view), from: .init(animatedView: show ? plusButton : plusButton, primatyView: show ? homeVC.view : transactionVC.view), with: transitionContext, isPresenting: show)
    }
    
    private func presentImageVC(_ toViewController: TransitionViews, from fromViewController: TransitionViews, with transitionContext: UIViewControllerContextTransitioning, isPresenting:Bool) {
        guard let fromAnimated = beginTransactionPressedView,
              let toAnimated = toViewController.animatedView ?? toViewController.animatedRegView,
              let fromView = fromViewController.primatyView,
              let toView = toViewController.primatyView
        else {
            fatalError()
        }
        print("isPresentingisPresenting: ", isPresenting)
        let frmVC = (transitionContext.viewController(forKey: .from))?.navigationController
                     
        let bar = frmVC?.navigationBar.frame.height ?? 0
        let barHeight = (frmVC?.isNavigationBarHidden ?? true) ? 0 : (bar + (frmVC?.view.safeAreaInsets.top ?? 0))
        
        let containerView = transitionContext.containerView
        let fromViewFrame = containerView.convert(fromAnimated.frame, from: fromAnimated)
        let fromFrame:CGRect = .init(x: canDivideFrame ? fromViewFrame.minX / 2 : fromViewFrame.minX, y: fromViewFrame.minY + barHeight, width: fromViewFrame.width, height: fromViewFrame.height)
        //.init(origin: fromViewFrame.origin, size: .init(width: 40, height: 40))
        let holder = toView.backgroundColor
        print(fromFrame, " y5tgerfwd")
        print(fromViewFrame, " hyref")
        print(beginTransactionPressedView?.frame, " ntyhrtegfdsfgrt")
        
        containerView.addSubview(toView)
        if !isPresenting {
            containerView.addSubview(fromView)
        }
        var toFrame1:CGRect = containerView.convert(toView.frame, from:toView)
        if isPresenting {
            toView.layer.cornerRadius =  fromAnimated.layer.cornerRadius
            toView.layer.masksToBounds = true
            toFrame1.origin = .init(x: 0, y: 0)
            
            toFrame1.size = .init(width: toFrame1.size.width, height: toFrame1.size.height + barHeight)
         //   toFrame1.size = toView.frame.size
            toView.frame = fromFrame
            toView.backgroundColor = K.Colors.link.withAlphaComponent(0.2)
        }
        
print(toFrame1, "rfgytrfe")
        
        if isPresenting && fromFrame.minY <= 130 {
            UIView.animate(withDuration: duration / 1.5, animations: {
                let window = UIApplication.shared.keyWindow?.frame ?? .zero
                toView.frame.origin = .init(x: window.width / 4, y: window.height / 4)
            })
        }
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            if !isPresenting {
                fromView.frame = fromFrame
                fromView.backgroundColor = K.Colors.link.withAlphaComponent(0.2)
                fromView.subviews.forEach({$0.alpha = 0})
                fromView.layer.cornerRadius = toAnimated.layer.cornerRadius
            } else {
                toView.frame = toFrame1
                toView.layer.cornerRadius = 0
                toView.backgroundColor = holder
            }
            
        }
        
        animator.addCompletion { position in
            transitionContext.completeTransition(position == .end)
            if !isPresenting {
                fromView.removeFromSuperview()
            }
        }
        animator.startAnimation()
    }
    
    
}

extension AnimatedTransitioningManager:UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
            return self
        }
}

extension AnimatedTransitioningManager {
    //will animate from /from to /to
    struct AnimatedView {
        let from:UIView
        let to:UIView
    }
}
