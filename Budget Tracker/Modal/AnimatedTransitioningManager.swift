//
//  AnimatedImageManagerNav.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 11.10.2023.
//

import UIKit
/*
final class AnimatedTransitioningManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    
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
        if let movieVC = fromVC as? MovieVC ?? toVC as? MovieVC,
           let imageVC = toVC as? ImageVC ?? fromVC as? ImageVC {
            self.transactionPerform(movieVC: movieVC, imageVC: imageVC, using: transitionContext)
        } else if let movieVC = fromVC as? MovieVC ?? toVC as? MovieVC,
                  let listVC = toVC as? MovieListVC ?? fromVC as? MovieListVC {
            self.transactionPerform(movieVC: movieVC, listVC: listVC, using: transitionContext)
        } else if let movieVC = fromVC as? MovieVC ?? toVC as? MovieVC,
                  let tabvc = (toVC as? MovieListVC ?? fromVC as? MovieListVC) ?? (toVC as? TabBarVC ?? fromVC as? TabBarVC),
                  let tabbarVC = tabvc as? UITabBarController
        {
            self.transactionPerform(movieVC: movieVC, tabVC: tabbarVC as! TabBarVC, using: transitionContext)
        } else {
            fatalError()
        }
        
    }
    
}

//movieListVC - movieVC
private extension AnimatedTransitioningManager {
    func transactionPerform(movieVC:MovieVC, tabVC:TabBarVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? MovieVC) != nil
        let animFrame:CGRect = .init(x: 100, y: 100, width: 0, height: 0)
        movieVC.frameHolder = animFrame
        let listVC = tabVC.viewControllers?.first(where: {$0 is MovieListVC}) as? MovieListVC
        movieVC.movieImage.frame = .init(origin: movieVC.movieImage.frame.origin, size: listVC?.selectedImageView?.frame.size ?? movieVC.movieImage.frame.size)
        presentImageVC(.init(animatedView: show ? listVC?.selectedImageView : movieVC.movieImage,
                             primatyView: show ? tabVC.view : movieVC.view,
                             animatedFrame: !show ? movieVC.frameHolder : animFrame
                            ),
                       from: .init(animatedView: show ? movieVC.movieImage : listVC?.selectedImageView,
                                   primatyView: show ? movieVC.view : tabVC.view,
                                   animatedFrame: show ? movieVC.frameHolder : animFrame
                                  ),
                       with: transitionContext,
                       isPresenting: show)
    }
    
    func transactionPerform(movieVC:MovieVC, listVC:MovieListVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? MovieVC) != nil
        let animFrame:CGRect = .init(x: 100, y: 100, width: 0, height: 0)
        movieVC.frameHolder = animFrame
        movieVC.movieImage.frame = .init(origin: movieVC.movieImage.frame.origin, size: listVC.selectedImageView?.frame.size ?? movieVC.movieImage.frame.size)
        
        let isReg = listVC.selectedImageView == nil
        presentImageVC(.init(animatedView: isReg ? nil : (show ? listVC.selectedImageView : movieVC.movieImage),
                             primatyView: show ? listVC.view : movieVC.view,
                             animatedFrame: !show ? movieVC.frameHolder : animFrame,
                             animatedRegView: !isReg ? nil : (show ? listVC.shakeButton : movieVC.movieImage)
                            ),
                       from: .init(animatedView: isReg ? nil : (show ? movieVC.movieImage : listVC.selectedImageView),
                                   primatyView: show ? movieVC.view : listVC.view,
                                   animatedFrame: show ? movieVC.frameHolder : animFrame,
                                   animatedRegView: isReg ? (show ? movieVC.movieImage : listVC.shakeButton) : nil
                                  ),
                       with: transitionContext,
                       isPresenting: show)
    }
}


//movieVC - ImgVC
private extension AnimatedTransitioningManager {
    struct TransitionViews {
        let animatedView:UIImageView?
        let primatyView:UIView?
        var animatedFrame:CGRect? = nil
        var animatedRegView:UIView? = nil
        var viewFrame:CGRect? = nil
    }
    
    func transactionPerform(movieVC:MovieVC, imageVC:ImageVC, using transitionContext: UIViewControllerContextTransitioning) {
        let show = (transitionContext.viewController(forKey: .from) as? MovieVC) != nil
        
        presentImageVC(.init(animatedView: show ? imageVC.imgView : movieVC.movieImage, primatyView: show ? imageVC.view : movieVC.view), from: .init(animatedView: show ? movieVC.movieImage : imageVC.imgView, primatyView: show ? movieVC.view : imageVC.view), with: transitionContext, isPresenting: show)
    }
    
    private func presentImageVC(_ toViewController: TransitionViews, from fromViewController: TransitionViews, with transitionContext: UIViewControllerContextTransitioning, isPresenting:Bool) {
        guard let fromAnimated = fromViewController.animatedView ?? fromViewController.animatedRegView,
              let toAnimated = toViewController.animatedView ?? toViewController.animatedRegView,
              let fromView = fromViewController.primatyView,
              let toView = toViewController.primatyView
        else {
            fatalError()
        }
        toAnimated.alpha = 0
        print("isPresentingisPresenting: ", isPresenting)
        let containerView = transitionContext.containerView
        let snapshotContentView = UIView()
        snapshotContentView.frame =  containerView.convert(fromAnimated.frame, from: fromAnimated)
        
        let fromImageView = UIImageView()
        fromImageView.clipsToBounds = true
        fromImageView.contentMode = fromAnimated.contentMode
        fromImageView.image = (fromAnimated as? UIImageView)?.image
        toViewController.animatedView?.image = (fromAnimated as? UIImageView)?.image
        let imgFrame = containerView.convert(fromAnimated.frame, from: fromAnimated)
        
        fromImageView.layer.cornerRadius =  fromAnimated.layer.cornerRadius
        fromImageView.frame = imgFrame
        
        containerView.addSubview(toView)
        containerView.addSubview(snapshotContentView)
        containerView.addSubview(fromImageView)
        
        toView.alpha = 0
        snapshotContentView.alpha = 0
        fromView.alpha = 1
        
        var toFrame1 = containerView.convert(toAnimated.frame, from: toAnimated)
        toFrame1.size = toAnimated.frame.size
        
        let animatorPuls = UIViewPropertyAnimator(duration: duration / 2, curve: .easeIn, animations: {
            toView.alpha = 1
            fromView.alpha = 0
        })
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            fromImageView.frame = toFrame1
            fromImageView.frame.size = toAnimated.frame.size
            fromImageView.layer.cornerRadius = 0
            snapshotContentView.backgroundColor = toView.backgroundColor
            
        }
        
        animator.addCompletion { position in
            UIView.animate(withDuration: 0.24, delay: 0, options: .allowUserInteraction, animations: {
                fromImageView.frame.size = toAnimated.frame.size
                snapshotContentView.alpha = 0
            }, completion: { _ in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    UIView.animate(withDuration: 0.24, delay: 0, options: .allowUserInteraction, animations: {
                        toAnimated.alpha = 1
                        fromImageView.alpha = 0
                    }, completion: { _ in
                        fromImageView.removeFromSuperview()
                        snapshotContentView.removeFromSuperview()
                    })
                } else {
                    toAnimated.alpha = 1
                    fromImageView.alpha = 0
                    fromImageView.removeFromSuperview()
                    snapshotContentView.removeFromSuperview()
                }
            })
            transitionContext.completeTransition(position == .end)
            
        }
        animatorPuls.startAnimation()
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

*/
