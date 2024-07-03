import UIKit

public struct Colors {
    let text: UIColor
    let main: UIColor
    let secondaryText: UIColor
    let background: UIColor

    public init(text: UIColor, main: UIColor, secondaryText: UIColor, background: UIColor) {
        self.text = text
        self.main = main
        self.secondaryText = secondaryText
        self.background = background
    }

    static func def() -> Self {
        .init(text: .black, main: .blue, secondaryText: .lightGray, background: .white)
    }
}
