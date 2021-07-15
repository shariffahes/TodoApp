import UIKit
class SwiftDisclosureIndicator: UIView {
    @IBInspectable var color = UIColor.black {
    didSet {
      setNeedsDisplay()
    }
  }
    override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    
        let x = self.bounds.maxX — 3
        let y = self.bounds.midY
    let R = CGFloat(4.5)
    CGContextMoveToPoint(context, x - R, y - R)
    CGContextAddLineToPoint(context, x, y)
    CGContextAddLineToPoint(context, x - R, y + R)
    CGContextSetLineCap(context, CGLineCap.Square)
    CGContextSetLineJoin(context, CGLineJoin.Miter)
    CGContextSetLineWidth(context, 2)
    color.setStroke()
    CGContextStrokePath(context)
  }
}
