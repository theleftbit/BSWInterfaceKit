//
//  Created by Michele Restuccia on 18/10/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//

#if canImport(UIKit)

//https://www.raywenderlich.com/2297-how-to-make-a-custom-control-tutorial-a-reusable-slider#toc-anchor-009

import UIKit
import QuartzCore

public class RangeSlider: UIControl {
    
    public struct Configuration {
        public let trackTintColor: UIColor
        public let trackHighlightTintColor: UIColor
        public let thumbTintColor: UIColor
        public let curvaceousness: CGFloat
        
        public init(trackTintColor: UIColor,
                    trackHighlightTintColor: UIColor,
                    thumbTintColor: UIColor,
                    curvaceousness: CGFloat = 1.0) {
            self.trackTintColor = trackTintColor
            self.trackHighlightTintColor = trackHighlightTintColor
            self.thumbTintColor = thumbTintColor
            self.curvaceousness = curvaceousness
        }
    }
    
    public struct VM {
        public let minimumValue: Double
        public let maximumValue: Double
        
        public init(minimumValue: Double, maximumValue: Double) {
            self.minimumValue = minimumValue
            self.maximumValue = maximumValue
        }
    }
    
    public init(configuration: Configuration) {
        super.init(frame: .zero)
        
        trackTintColor = configuration.trackTintColor
        trackHighlightTintColor = configuration.trackHighlightTintColor
        thumbTintColor = configuration.thumbTintColor
        curvaceousness = configuration.curvaceousness
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configureFor(viewModel: VM) {
        minimumValue = viewModel.minimumValue
        maximumValue = viewModel.maximumValue
        lowerValue = viewModel.minimumValue
        upperValue = viewModel.maximumValue
    }
    
    public func updateValues(lowerValue: Double, upperValue: Double) {
        self.lowerValue = lowerValue
        self.upperValue = upperValue
    }
    
    override public var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 32)
    }
    
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbLayer = RangeSliderThumbLayer()
    private let upperThumbLayer = RangeSliderThumbLayer()
    private var previousLocation = CGPoint()
    
    public var lowerValue: Double = 0.2 {
        didSet { updateLayerFrames() }
    }
    
    public var upperValue: Double = 0.8 {
        didSet { updateLayerFrames() }
    }
    
    private var minimumValue: Double = 0.0 {
        didSet { updateLayerFrames() }
    }
    
    private var maximumValue: Double = 10.0 {
        didSet { updateLayerFrames() }
    }
    
    private var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet { trackLayer.setNeedsDisplay() }
    }
    
    private var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet { trackLayer.setNeedsDisplay() }
    }
    
    private var thumbTintColor: UIColor = .white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    private var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    private var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    override public var frame: CGRect {
        didSet { updateLayerFrames() }
    }
    
    override public var bounds: CGRect {
        didSet { updateLayerFrames() }
    }

    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue)-2)
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: -3.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue)+2)
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: -3.0,
                                       width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    private func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    private func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    // Touch handlers
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        previousLocation = location
        
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
    
    class RangeSliderThumbLayer: CALayer {
        weak var rangeSlider: RangeSlider?
        var highlighted: Bool = false {
            didSet { setNeedsDisplay() }
        }
        
        override func draw(in ctx: CGContext) {
            if let slider = rangeSlider {
                let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
                let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
                let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
                
                // Fill - with a subtle shadow
                let shadowColor = UIColor.gray
                ctx.setShadow(offset: CGSize(width: 0.0, height: 1.0), blur: 1.0, color: shadowColor.cgColor)
                ctx.setFillColor(slider.thumbTintColor.cgColor)
                ctx.addPath(thumbPath.cgPath)
                ctx.fillPath()
                
                // Outline
                ctx.setStrokeColor(shadowColor.cgColor)
                ctx.setLineWidth(0.5)
                ctx.addPath(thumbPath.cgPath)
                ctx.strokePath()
                
                if highlighted {
                    ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
                    ctx.addPath(thumbPath.cgPath)
                    ctx.fillPath()
                }
            }
        }
    }
    
    class RangeSliderTrackLayer: CALayer {
        weak var rangeSlider: RangeSlider?
        private let heightTrackLine: CGFloat = 3
        
        override func draw(in ctx: CGContext) {
            if let slider = rangeSlider {
                // Clip
                let cornerRadius = bounds.height * slider.curvaceousness / 2.0
                let mainRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: heightTrackLine)
                let path = UIBezierPath(roundedRect: mainRect, cornerRadius: cornerRadius)
                ctx.addPath(path.cgPath)
                
                // Fill the track
                ctx.setFillColor(slider.trackTintColor.cgColor)
                ctx.addPath(path.cgPath)
                ctx.fillPath()
                
                // Fill the highlighted range
                ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
                let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
                let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
                let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: heightTrackLine)
                ctx.fill(rect)
            }
        }
    }
}

#endif
