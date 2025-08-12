import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    private var g: CAGradientLayer {
        layer as! CAGradientLayer
    }
    
    var colors: [UIColor] = [] {
        didSet {
            g.colors = colors.map { $0.cgColor }
        }
    }
    var locations: [NSNumber]? {
        didSet { g.locations = locations }
    }
    
    var startPoint: CGPoint {
        get { g.startPoint }
        set { g.startPoint = newValue }
    }
    var endPoint: CGPoint {
        get { g.endPoint }
        set { g.endPoint = newValue }
    }
}
