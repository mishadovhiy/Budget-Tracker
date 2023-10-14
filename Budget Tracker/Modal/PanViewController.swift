//
//  PanViewController.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 14.10.2023.
//

import UIKit

class PanViewController {
    
    private let vc:UIViewController
    var delegate:PanViewControllerProtocol?
    private var properies:ScrollProperties = .init()

    init(vc:UIViewController) {
        self.vc = vc
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(pinched(_:)))
        gesture.name = "PanViewControllerUIPanGestureRecognizer"
        vc.view.addGestureRecognizer(gesture)
    //    vc.createPanIndicator()
    }
       
    deinit {
        let gesture = vc.view.gestureRecognizers?.first(where: {$0.name == "PanViewControllerUIPanGestureRecognizer"})
        gesture?.delegate = nil
        gesture?.isEnabled = false
    }
    
    @objc private func pinched(_ sender:UIPanGestureRecognizer) {
        let finger = sender.location(in: nil)
        let height = vc.view.frame.height
        if sender.state == .began {
            properies.scrolling = (finger.y  - height) < 80
            properies.wasShowing = properies.vcShowing
            properies.startScrollingPosition = finger.y
         //   properies.isHidding = false
            touches(true)
        }
        let currentPosition = self.vc.view.frame.minY
        let toHide:CGFloat = properies.wasShowing ? 200 : 80
        let isHidding = currentPosition > toHide ? false : true
        var stateChanged = false
        if isHidding != properies.isHidding {
            properies.isHidding = isHidding
            stateChanged = true
        }
        if properies.scrolling || properies.vcShowing {
            if sender.state == .began || sender.state == .changed {
                let newPosition = (finger.y - height) >= 0 ? 0 : (finger.y - height)
                let newResultPosition = (newPosition + properies.toHideVC) - properies.startScrollingPosition
                let percentCalc = (newResultPosition / 2) / properies.toHideVC
                let percent = percentCalc <= 0 ? 0 : (percentCalc >= 1 ? 1 : percentCalc)
                print(newPosition, " pinched ", percent)
                self.vc.view.layer.cornerRadius = 140 * percent
           ///     self.vc.view.layer.move(.top, value: newResultPosition > 0 ? newResultPosition : (newResultPosition / 15))
                if stateChanged && percent >= 0.1 {
              ///      vc.vibrate(style: .soft)
                }
            } else if sender.state == .ended || sender.state == .cancelled {
                properies.isHidding = false
                touches(false)
                toggleView(show: isHidding, animated: true)
                
            }
        }
    }
    

    private func toggleView(show:Bool, animated:Bool = true, completion:((_ show:Bool)->())? = nil) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
      //      self.vc.view.layer.move(.top, value: show ? 0 : self.properies.toHideVC)
        }, completion: { _ in
            if !show {
                self.properies.vcShowing = false
                self.properies.scrolling = false
                completion?(false)
            } else {
                self.properies.vcShowing = true
                self.properies.scrolling = false
                completion?(true)
            }
        })
        if !show {
            self.dismissVC() {
                
            }
        }
    }
    
    
    private func dismissVC(completion:(()->())? = nil) {
        vc.navigationController?.popViewController(animated: true)
        completion?()
    }
    
    
    private func touches(_ begun:Bool) {
    /*    let panIndocator = vc.view.subviews.first(where: {
            $0.layer.name == UIViewController.panIndicatorLayerName
        })
        UIView.animate(withDuration: 0.38, animations: {
            panIndocator?.alpha = begun ? 0.3 : 0.1
            self.vc.view.layer.cornerRadius = 0
        })*/
    }

    
}

protocol PanViewControllerProtocol {
    func panDismissed()
    func panAppeared()
}

extension PanViewController {
    struct ScrollProperties {
        var scrolling:Bool = false
        var wasShowing:Bool = false
        var vcShowing:Bool = true
        var startScrollingPosition:CGFloat = 0
        var isHidding:Bool = false
        var toHideVC:CGFloat {
            return UIApplication.shared.keyWindow?.frame.height ?? 0
        }
    }
}
