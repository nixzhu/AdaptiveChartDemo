//
//  AdaptiveChart.swift
//  AdaptiveChartDemo
//
//  Created by NIX on 15/4/4.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import UIKit

public class AdaptiveChart {

    private var size: CGSize
    private var edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    private var graphColor = UIColor.greenColor()
    private var shadowColor = UIColor.greenColor().colorWithAlphaComponent(0.95)
    private var shadowOffset = CGSizeMake(0, 0)
    private var shadowBlurRadius: CGFloat = 5.0

    private var textFont = UIFont.systemFontOfSize(12)
    private var textColor = UIColor.redColor()

    private var barWidthPercentage: CGFloat = 0.618

    private var showNumber: Bool = false
    private var numberFont = UIFont.systemFontOfSize(8)
    private var numberColor = UIColor.greenColor()

    public enum NumberType {
        case Int
        case Double
    }
    private var numberType: NumberType = .Double


    private var data: [(String, Double)]?

    public init(size: CGSize) {
        self.size = size
    }

    public func setEdgeInsets(edgeInsets: UIEdgeInsets) -> AdaptiveChart {
        self.edgeInsets = edgeInsets
        return self
    }

    public func setGraphColor(graphColor: UIColor) -> AdaptiveChart {
        self.graphColor = graphColor
        self.shadowColor = graphColor.colorWithAlphaComponent(0.95)
        return self
    }

    public func setShadowColor(shadowColor: UIColor) -> AdaptiveChart {
        self.shadowColor = shadowColor
        return self
    }

    public func setShadowOffset(shadowOffset: CGSize) -> AdaptiveChart {
        self.shadowOffset = shadowOffset
        return self
    }

    public func setShadowBlurRadius(shadowBlurRadius: CGFloat) -> AdaptiveChart {
        self.shadowBlurRadius = shadowBlurRadius
        return self
    }

    public func setTextFont(textFont: UIFont) -> AdaptiveChart {
        self.textFont = textFont
        return self
    }

    public func setTextColor(textColor: UIColor) -> AdaptiveChart {
        self.textColor = textColor
        return self
    }

    public func setBarWidthPercentage(barWidthPercentage: CGFloat) -> AdaptiveChart {
        if barWidthPercentage > 1 {
            self.barWidthPercentage = 1
        } else if barWidthPercentage < 0 {
            self.barWidthPercentage = 0
        } else {
            self.barWidthPercentage = barWidthPercentage
        }
        return self
    }

    public func setShowNumber(showNumber: Bool) -> AdaptiveChart {
        self.showNumber = showNumber
        return self
    }

    public func setNumberFont(numberFont: UIFont) -> AdaptiveChart {
        self.numberFont = numberFont
        return self
    }

    public func setNumberColor(numberColor: UIColor) -> AdaptiveChart {
        self.numberColor = numberColor
        return self
    }

    public func setNumberType(numberType: NumberType) -> AdaptiveChart {
        self.numberType = numberType
        return self
    }

    public func setData(data: [(String, Double)]) -> AdaptiveChart {
        self.data = data
        return self
    }

    public enum ChartType {
        case Bar
        case Line
    }



    private struct ChartParams {
        var barTopMargin: CGFloat
        var barLeftMargin: CGFloat
        var barRightMargin: CGFloat
        var barBottomMargin: CGFloat
        var minBarRightMargin: CGFloat

        var maxNameWidth: CGFloat
        var maxNameHeight: CGFloat

        var rotateAngle: CGFloat

        var nameWidths = [CGFloat]()
        var maxValue: Double
    }

    private func compute() -> ChartParams? {
        if let data = data {

            let barTopMargin: CGFloat
            if (showNumber) {
                barTopMargin = edgeInsets.top + ceil(numberFont.lineHeight * 1.0)
            } else {
                barTopMargin = edgeInsets.top
            }

            let barLeftMargin = edgeInsets.left
            let minBarRightMargin = edgeInsets.right

            // 找出 name 中最长的，用于计算 barBottomMargin
            // 以及所有的 nameWidths

            let attributes = [NSFontAttributeName: textFont]

            var nameWidths = [CGFloat]()
            var maxValue: Double = 0
            var maxNameWidth: CGFloat = 0
            var maxNameHeight: CGFloat = 0

            for (name, value) in data {
                if value > maxValue {
                    maxValue = value
                }

                let nameRect = name.boundingRectWithSize(CGSize(width: CGFloat(FLT_MAX), height: 20), options: .UsesLineFragmentOrigin | .UsesFontLeading, attributes: attributes, context: nil)
                println("name: \(name), nameRect, \(nameRect)")

                let nameRectWidth = nameRect.width

                nameWidths.append(nameRectWidth)

                if nameRectWidth > maxNameWidth {
                    maxNameWidth = nameRectWidth
                }

                if nameRect.height > maxNameHeight {
                    maxNameHeight = nameRect.height
                }
            }

            // Text 的旋转角度

            let rotateAngle = CGFloat(M_PI * 0.2)
            let ratio = cos(rotateAngle)

            // 因为方程复杂，所以使用牛顿迭代法，逼近最佳的 barWidth

            var currentTryRightMargin: CGFloat = 1
            var nextTryRightMargin: CGFloat = 0

            while true {

                var currentBarWidth = (size.width - barLeftMargin - currentTryRightMargin) / CGFloat(nameWidths.count)

                func nMax() -> CGFloat {
                    var _max: CGFloat = 0
                    for i in 0..<nameWidths.count {
                        let newValue = nameWidths[i] * ratio + minBarRightMargin - CGFloat((nameWidths.count - 1) - i) * currentBarWidth
                        if newValue > _max {
                            _max = newValue
                        }
                    }

                    return _max
                }

                let fN = max(nMax() -  currentBarWidth * 0.5, minBarRightMargin) - currentTryRightMargin
                let fpN = 1 / CGFloat(nameWidths.count) * 0.5 - 1

                nextTryRightMargin = currentTryRightMargin - fN/fpN
                
                if abs(nextTryRightMargin - currentTryRightMargin) < 0.01 {
                    break
                }
                
                currentTryRightMargin = nextTryRightMargin
            }

            var barRightMargin = currentTryRightMargin
            var barBottomMargin = maxNameWidth * sin(rotateAngle) + maxNameHeight * cos(rotateAngle) + edgeInsets.bottom

            return ChartParams(barTopMargin: barTopMargin, barLeftMargin: barLeftMargin, barRightMargin: barRightMargin, barBottomMargin: barBottomMargin, minBarRightMargin: minBarRightMargin, maxNameWidth: maxNameWidth, maxNameHeight: maxNameHeight, rotateAngle: rotateAngle, nameWidths: nameWidths, maxValue: maxValue)
        }

        return nil

    }

    public func imageWithChartType(chartType: ChartType) -> UIImage {

        if let data = data, let chartParams = compute() {

            var chartParams = chartParams

            let scale = UIScreen.mainScreen().scale
            UIGraphicsBeginImageContextWithOptions(size, false, scale)

            let imageContext = UIGraphicsGetCurrentContext()

            var barFullWidth = (size.width - chartParams.barLeftMargin - chartParams.barRightMargin) / CGFloat(data.count)

            // 如果 text 不需要倾斜，那就重新计算边界和 barFullWidth
            if chartParams.maxNameWidth <= barFullWidth {
                chartParams.barRightMargin = chartParams.minBarRightMargin
                chartParams.barBottomMargin = chartParams.maxNameHeight * cos(chartParams.rotateAngle) + edgeInsets.bottom

                barFullWidth = (size.width - chartParams.barLeftMargin - chartParams.barRightMargin) / CGFloat(data.count)
            }

            let barWidth = barWidthPercentage * barFullWidth

            let barFullHeight = size.height - (chartParams.barTopMargin + chartParams.barBottomMargin)

            if chartType == .Bar {
                for (index, (name, value)) in enumerate(data) {

                    let centerX = (CGFloat(index) + 0.5) * barFullWidth + chartParams.barLeftMargin

                    let topY = barFullHeight * CGFloat(1.0 - value / chartParams.maxValue) + chartParams.barTopMargin

                    // bars

                    CGContextSaveGState(imageContext)

                    // shadow

                    CGContextSetShadowWithColor(imageContext, shadowOffset, shadowBlurRadius, shadowColor.CGColor)

                    let x = centerX - barWidth * 0.5
                    let y = chartParams.barTopMargin + barFullHeight
                    let width = barWidth
                    let height = y - topY

                    let bar = UIBezierPath(roundedRect: CGRect(x: x, y: topY, width: width, height: height), cornerRadius: barWidth * 0.1)

                    graphColor.setFill()
                    
                    bar.fill()
                    
                    CGContextRestoreGState(imageContext)
                }
                
            } else if chartType == .Line {

                let baseLine = UIBezierPath()
                baseLine.lineWidth = 1.0 / scale

                let baseLineY = size.height - chartParams.barBottomMargin
                baseLine.moveToPoint(CGPoint(x: chartParams.barLeftMargin, y: baseLineY))
                baseLine.addLineToPoint(CGPoint(x: size.width - chartParams.barRightMargin, y: baseLineY))

                graphColor.colorWithAlphaComponent(0.618).setStroke()
                baseLine.stroke()

                let line = UIBezierPath()

                CGContextSaveGState(imageContext)

                for (index, (name, value)) in enumerate(data) {

                    let centerX = (CGFloat(index) + 0.5) * barFullWidth + chartParams.barLeftMargin

                    let topY = barFullHeight * CGFloat(1.0 - value / chartParams.maxValue) + chartParams.barTopMargin

                    let point = CGPoint(x: centerX, y: topY)
                    if index == 0 {
                        line.moveToPoint(point)
                    } else {
                        line.addLineToPoint(point)
                    }
                }

                graphColor.colorWithAlphaComponent(0.618).setStroke()

                line.stroke()

                CGContextRestoreGState(imageContext)

                // dots
                CGContextSaveGState(imageContext)

                // shadow

                CGContextSetShadowWithColor(imageContext, shadowOffset, shadowBlurRadius, shadowColor.CGColor)

                for (index, (name, value)) in enumerate(data) {

                    let centerX = (CGFloat(index) + 0.5) * barFullWidth + chartParams.barLeftMargin

                    let topY = barFullHeight * CGFloat(1.0 - value / chartParams.maxValue) + chartParams.barTopMargin

                    let point = CGPoint(x: centerX, y: topY)
                    let dot = UIBezierPath(arcCenter: point, radius: barWidth * 0.15, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)

                    graphColor.setFill()

                    dot.fill()
                }
                
                CGContextRestoreGState(imageContext)
            }

            for (index, (name, value)) in enumerate(data) {

                let centerX = (CGFloat(index) + 0.5) * barFullWidth + chartParams.barLeftMargin

                let topY = barFullHeight * CGFloat(1.0 - value / chartParams.maxValue) + chartParams.barTopMargin

                // Numbers
                if showNumber {
                    let numberAttributes = [
                        NSFontAttributeName: numberFont,
                        NSForegroundColorAttributeName: numberColor
                    ]

                    let number: String

                    if numberType == .Int {
                        number = NSString(format: "%.0f", value) as String
                    } else {
                        number = "\(value)"
                    }

                    let numberRect = number.boundingRectWithSize(CGSize(width: CGFloat(FLT_MAX), height: 20), options: .UsesLineFragmentOrigin | .UsesFontLeading, attributes: numberAttributes, context: nil)

                    let realNumberRect = CGRect(x: centerX - numberRect.width * 0.5, y: topY - (numberRect.height * 1.3), width: numberRect.width, height: numberRect.height)
                    number.drawInRect(realNumberRect, withAttributes: numberAttributes)
                }


                // Text
                let string = name

                let nameAttributes = [
                    NSFontAttributeName: textFont,
                    NSForegroundColorAttributeName: textColor
                ]

                // 需要倾斜
                if chartParams.maxNameWidth > barFullWidth {
                    CGContextSaveGState(imageContext)

                    CGContextTranslateCTM(imageContext, centerX, chartParams.barTopMargin + barFullHeight)
                    CGContextRotateCTM(imageContext, chartParams.rotateAngle)

                    let stringRect = CGRect(x: 3, y: 3, width: 300, height: chartParams.maxNameHeight)
                    string.drawInRect(stringRect, withAttributes: nameAttributes)

                    CGContextRestoreGState(imageContext)

                } else {
                    let width = chartParams.nameWidths[index]
                    let stringRect = CGRect(x: centerX - width * 0.5, y: chartParams.barTopMargin + barFullHeight + 5, width: width+5, height: chartParams.maxNameHeight)
                    string.drawInRect(stringRect, withAttributes: nameAttributes)
                }

            }
            
            // image
            var cgImage:CGImageRef = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
            UIGraphicsEndImageContext();
            
            let image = UIImage(CGImage: cgImage, scale: scale, orientation: .Up)
            
            return image!
            
        } else {
            return UIImage()
        }
    }
}
