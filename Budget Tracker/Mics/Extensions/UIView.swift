//
//  UIView.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 28.03.2022.
//  Copyright © 2022 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                .linear)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    var toImage: UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { (context) in
            layer.render(in: context.cgContext)
        }
        
    }
    
    func shadow(opasity:Float = 0.6, black:Bool = false) {
        DispatchQueue.main.async {
            self.layer.shadowColor = !black ? K.Colors.secondaryBackground2.cgColor : UIColor.black.cgColor
            self.layer.shadowOffset = .zero
            self.layer.shadowRadius = 10
            self.layer.shadowOpacity = opasity
        }
    }
    
    func addBluer(frame:CGRect? = nil, style:UIBlurEffect.Style = (.init(rawValue: -1000) ?? .regular), insertAt:Int? = nil) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)//prominent//dark//regular
        let bluer = UIVisualEffectView(effect: blurEffect)
        //bluer.frame = frame ?? .init(x: 0, y: 0, width: frame?.width ?? self.frame.width, height: frame?.height ?? self.frame.height)
        // view.insertSubview(blurEffectView, at: 0)
        let vibracity = UIVisualEffectView(effect: blurEffect)
        // vibracity.contentView.addSubview()
        bluer.contentView.addSubview(vibracity)
        let constaints:[NSLayoutConstraint.Attribute : CGFloat] = [.leading:0, .top:0, .trailing:0, .bottom:0]
        vibracity.addConstaits(constaints, superV: bluer)
        if let at = insertAt {
            self.insertSubview(bluer, at: at)
        } else {
            self.addSubview(bluer)
        }
        
        bluer.addConstaits(constaints, superV: self)
        
        return bluer
    }
    func addConstaits(_ constants:[NSLayoutConstraint.Attribute:CGFloat], superV:UIView) {
        let layout = superV
        constants.forEach { (key, value) in
            let keyNil = key == .height || key == .width
            let item:Any? = keyNil ? nil : layout
            superV.addConstraint(.init(item: self, attribute: key, relatedBy: .equal, toItem: item, attribute: key, multiplier: 1, constant: value))
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
extension UIView {
    func contains(_ touches: Set<UITouch>) -> Bool {
        if let loc = touches.first?.location(in: self),
           frame.contains(loc) {
            return true
        } else {
            return false
        }
    }
    func removeWithAnimation(animation:CGFloat = 0.11, complation:(()->())? = nil) {
        UIView.animate(withDuration: animation, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            
            if let com = complation {
                com()
            }
            self.removeFromSuperview()
        }
    }
    func hideWithAnimation(_ hidden:Bool, animation:CGFloat = 0.11) {
        UIView.animate(withDuration: animation, animations: {
            self.isHidden = hidden
        })
    }
}
extension CALayer {
    enum CornerPosition {
        case top
        case btn
        case left
        case right
    }
    func cornerRadius(at:CornerPosition, value:CGFloat?) {
        switch at {
        case .top:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .btn:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .left:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .right:
            self.cornerRadius = value ?? (self.frame.height / 2)
            self.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    enum MoveDirection {
        case top
        case left
    }
    
    func move(_ direction:MoveDirection, value:CGFloat) {
        switch direction {
        case .top:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, 0, value, 0)
        case .left:
            self.transform = CATransform3DTranslate(CATransform3DIdentity, value, 0, 0)
        }
    }
    enum KeyPath:String {
        case height = "bounds.size.height"
        case background = "backgroundColor"
        case stokeEnd = "strokeEnd"
        func from(_ view:CALayer) -> Any {
            switch self {
            case .height:
                return view.bounds.size.height
            case .background:
                return view.backgroundColor ?? UIColor.black.cgColor
            case .stokeEnd:
                return 0
            }
        }
        
        func to(_ view:CALayer) -> Any? {
            switch self {
            case .height:
                return 0
            case .background:
                return nil
            case .stokeEnd:
                return 1
            }
        }
        
        func set(to:Any?, view:CALayer) {
            switch self {
            case .height:
                view.bounds.size.height = ((to ?? self.to(view)) as? CGFloat ?? 0)
            case .background:
                view.backgroundColor = ((to ?? self.to(view)) as! CGColor)
            case .stokeEnd:
break
            }
        }
    }
    
    enum AnimationKey:String {
        case general = "backgroundpress"
        case general1 = "backgroundpress1"
        
    }
    
    func performAnimation(key:KeyPath,
                          to:Any? = nil,
                          code:AnimationKey = .general,
                          duration:CGFloat = 0.5,
                          completion:(()->())? = nil
    ) {
        //   self.removeAnimation(forKey: key.rawValue)
        let animation = CABasicAnimation(keyPath: key.rawValue)
        animation.fromValue = key.from(self)
        animation.toValue = to ?? key.to(self)
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime()
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            key.set(to: to, view: self)
            completion?()
        }
        self.add(animation, forKey: code.rawValue)
        CATransaction.commit()
    }
    func zoom(value:CGFloat) {
        self.transform = CATransform3DMakeScale(value, value, 1)
    }
    func shadow(opasity:Float = 0.6, offset:CGSize = .init(width: 0, height: 0), color:UIColor? = nil, radius:CGFloat = 10) {
        self.shadowColor = (color ?? .black).cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = opasity
    }
    
    func drawSeparetor(space:CGPoint = .init(x: 0, y: 0), color:UIColor? = nil, opasity:Float = 1, y:CGFloat? = nil, width:CGFloat = 0.5) -> CAShapeLayer? {
        return self.drawLine([
            .init(x: space.x, y: y ?? self.frame.height),
            .init(x: self.frame.width - space.y, y: y ?? self.frame.height)
        ], color: color ?? K.Colors.separetor, width: width, opacity: opasity)
    }
    
    func createPath(_ lines:[CGPoint]) -> UIBezierPath {
        let linePath = UIBezierPath()
        var liness = lines
        guard let lineFirst = liness.first else { return .init() }
        linePath.move(to: lineFirst)
        liness.removeFirst()
        liness.forEach { line in
            linePath.addLine(to: line)
        }
        return linePath
    }
    
    func drawLine(_ lines:[CGPoint], color:UIColor? = K.Colors.separetor, width:CGFloat = 0.5, opacity:Float = 0.1, background:UIColor? = nil, insertAt:UInt32? = nil, name:String? = nil) -> CAShapeLayer? {
        
        let line = CAShapeLayer()
        let contains = self.sublayers?.contains(where: { $0.name == (name ?? "")} )
        let canAdd = name == nil ? true : !(contains ?? false)
        if canAdd {
            line.path = createPath(lines).cgPath
            line.opacity = opacity
            line.lineWidth = width
            line.strokeColor = (color ?? .red).cgColor
            line.name = name
            if let background = background {
                line.backgroundColor = background.cgColor
                line.fillColor = background.cgColor
            }
            if let at = insertAt {
                self.insertSublayer(line, at: at)
            } else {
                self.addSublayer(line)
            }
            
            return line
        } else {
            return nil
        }
        
    }
}
