import UIKit

// MARK: - UIFont Extension
extension UIFont {
    static func pantheonGoalsFont(size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: "aAhaWow", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
}

// MARK: - UIColor Extension
extension UIColor {
    static let pantheonGoalsLightBlue = UIColor(hex: "#BCE1F3")
    static let pantheonGoalsBlue = UIColor(hex: "#2B88CA")
    static let pantheonGoalsLightPurple = UIColor(hex: "#9CB2D6")
    static let pantheonGoalsDarkBlue = UIColor(hex: "#5A81C8")
    static let pantheonGoalsGold = UIColor(hex: "#C4903D")
    static let pantheonGoalsPurple = UIColor(hex: "#75768A")
    static let pantheonGoalsBeige = UIColor(hex: "#E4DDDB")
    static let pantheonGoalsDarkPurple = UIColor(hex: "#2B2972")
    static let pantheonGoalsGray = UIColor(hex: "#9B8F84")
    static let pantheonGoalsDarkRed = UIColor(hex: "#6B4162")
    
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - UIButton Extension
class PantheonGoalsButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        titleLabel?.font = .pantheonGoalsFont(size: 16)
        layer.cornerRadius = 12
        clipsToBounds = true
    }
}

// MARK: - UIView Extension
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
