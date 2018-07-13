//
//  Created by Pierluigi Cifani on 2/22/16.
//  Copyright © 2018 TheLeftBit SL SL. All rights reserved.
//

import BSWFoundation

extension UIView {

    @objc(bsw_addAutolayoutSubview:)
    public func addAutolayoutSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }

    @objc(bsw_findSubviewWithTag:)
    public func findSubviewWithTag(_ tag: NSInteger) -> UIView? {
        return subviews.find(predicate: { return $0.tag == tag} )
    }

    @objc(bsw_removeSubviewWithTag:)
    public func removeSubviewWithTag(_ tag: NSInteger) {
        findSubviewWithTag(tag)?.removeFromSuperview()
    }

    @objc(bsw_removeAllConstraints)
    public func removeAllConstraints() {
        let previousConstraints = constraints
        NSLayoutConstraint.deactivate(previousConstraints)
        removeConstraints(previousConstraints)
    }

    @objc(bsw_roundCorners:)
    public func roundCorners(radius: CGFloat = 10) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    @objc(bsw_getColorFromPoint:)
    public func getColorFromPoint(_ point: CGPoint) -> UIColor {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.translateBy(x: -point.x, y: -point.y);
        self.layer.render(in: context!)
        
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    @available(iOS 11.0, *)
    @discardableResult
    @objc(bsw_pinToSuperviewSafeLayoutEdges:)
    public func pinToSuperviewSafeLayoutEdges(withMargin margin: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let superView = superview else { return [] }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor, constant: margin.left),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor, constant: -margin.right),
            safeAreaLayoutGuide.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: margin.top),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -margin.bottom)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    @objc(bsw_pinToSuperviewWithEdges:)
    public func pinToSuperview(withEdges edges: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let superView = superview else { return [] }
        translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -edges.right),
            topAnchor.constraint(equalTo: superView.topAnchor, constant: edges.top),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -edges.bottom)
            ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    @objc(bsw_fillSuperviewWithMargin:)
    public func fillSuperview(withMargin margin: CGFloat)  -> [NSLayoutConstraint] {
        let inset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        return pinToSuperview(withEdges: inset)
    }

    @discardableResult
    @objc(bsw_centerInSuperview)
    public func centerInSuperview() -> [NSLayoutConstraint] {
        guard let superView = superview else { return [] }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            centerYAnchor.constraint(equalTo: superView.centerYAnchor)
            ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @nonobjc
    public class func instantiateFromNib<T: UIView>(_ viewType: T.Type) -> T? {
        let className = NSStringFromClass(viewType).components(separatedBy: ".").last!
        let bundle = Bundle(for: self)
        return bundle.loadNibNamed(className, owner: nil, options: nil)?.first as? T
    }

    @objc(bsw_instantiateFromNib)
    public class func instantiateFromNib() -> Self? {
        return instantiateFromNib(self)
    }
}
