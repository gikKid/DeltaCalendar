import UIKit

internal final class ValueCollectionViewCell: UICollectionViewCell {

	private let valueLabel: UILabel = {
		let size = TextSizeResources.big

		$0.textAlignment = .center
		$0.font = UIFont.systemFont(ofSize: size)
		return $0
	}(UILabel())

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    func configure<T: CustomStringConvertible>(text: T, isSelected: Bool, colors: Colors) {
		self.valueLabel.text = text.description
        self.valueLabel.textColor = isSelected ? colors.main : colors.secondaryText
	}

	private func setupView() {
		self.contentView.addSubview(self.valueLabel)

		self.valueLabel.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
	}
}
