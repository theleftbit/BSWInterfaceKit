//
//  Created by Michele Restuccia on 18/10/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//

#if canImport(UIKit)

//https://www.raywenderlich.com/2297-how-to-make-a-custom-control-tutorial-a-reusable-slider#toc-anchor-009

import UIKit
import QuartzCore

@available(iOS 17, *)
#Preview {
    let v = RangeSlider(configuration: RangeSlider.Configuration(range: .init(uncheckedBounds: (0, 10)), trackTintColor: .systemGray, trackHighlightTintColor: .systemBlue, thumbTintColor: .white))
    v.configureFor(viewModel: .init(selectedRange: .init(uncheckedBounds: (4,8))))
    return v
}

/// Creates a `UIControl` that allows the user to select a Range.
public class RangeSlider: UIControl, ViewModelConfigurable {
    
    /// All the properties that can be configured
    public struct Configuration {
        public let range: Range<Double>
        public let trackTintColor: UIColor
        public let trackHighlightTintColor: UIColor
        public let thumbTintColor: UIColor
        public let curvaceousness: CGFloat

        public init(range: Range<Double>,
                    trackTintColor: UIColor,
                    trackHighlightTintColor: UIColor,
                    thumbTintColor: UIColor,
                    curvaceousness: CGFloat = 1.0) {
            self.range = range
            self.trackTintColor = trackTintColor
            self.trackHighlightTintColor = trackHighlightTintColor
            self.thumbTintColor = thumbTintColor
            self.curvaceousness = curvaceousness
        }
    }
    
    public struct VM {
        public let selectedRange: Range<Double>
        
        public init(selectedRange: Range<Double>) {
            self.selectedRange = selectedRange
        }
    }
        
    public init(configuration: Configuration) {
        super.init(frame: .zero)
        
        trackTintColor = configuration.trackTintColor
        trackHighlightTintColor = configuration.trackHighlightTintColor
        thumbTintColor = configuration.thumbTintColor
        curvaceousness = configuration.curvaceousness
        minimumValue = configuration.range.lowerBound
        maximumValue = configuration.range.upperBound

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
        fatalError()
    }
    
    public func configureFor(viewModel: VM) {
        guard viewModel.selectedRange != lowerValue..<upperValue else { return }
        lowerValue = viewModel.selectedRange.lowerBound
        upperValue = viewModel.selectedRange.upperBound
    }
        
    override public var intrinsicContentSize: CGSize {
        .init(width: UIView.noIntrinsicMetric, height: 32)
    }
    
    private let trackLayer = RangeSliderTrackLayer()
    private let lowerThumbLayer = RangeSliderThumbLayer()
    private let upperThumbLayer = RangeSliderThumbLayer()
    private var previousLocation = CGPoint()
    
    public var selectedRange: Range<Double> {
        return .init(uncheckedBounds: (lowerValue, upperValue))
    }
    
    private var lowerValue: Double = 0.2 {
        didSet {
            updateLayerFrames()
            sendActions(for: .valueChanged)
        }
    }
    
    private var upperValue: Double = 0.8 {
        didSet {
            updateLayerFrames()
            sendActions(for: .valueChanged)
        }
    }
    
    public var shouldSnapOnUnits: Bool = false
    
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
        guard frame != .zero else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue)-2)
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: -3.0, width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue)+2)
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: -3.0, width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    private func positionForValue(_ value: Double) -> Double {
        let maxWidth = Double(bounds.width - thumbWidth)
        let position = maxWidth * (value - minimumValue) /
            (maximumValue - minimumValue)
        if shouldSnapOnUnits {
            let distance = maxWidth/(maximumValue - minimumValue)
            /// Normalize to the closest snap value
            let retval = Double(Int(position/distance)) * distance
            return retval + Double(thumbWidth / 2.0)
        } else {
            return position + Double(thumbWidth / 2.0)
        }
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
    
    var minSeparation: CGFloat {
        if shouldSnapOnUnits {
            return 1
        } else {
            return (maximumValue - minimumValue)/100
        }
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        previousLocation = location
        
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(value: lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - minSeparation)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(value: upperValue + deltaValue, toLowerValue: lowerValue + minSeparation, upperValue: maximumValue)
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
        
        @MainActor
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
        
        @MainActor
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
