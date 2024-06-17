import UIKit

internal final class ValueCollectionViewCell: UICollectionViewCell {

	private let valueLabel: UILabel = {
		let size = TextSizeResources.big

		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: size)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure<T: CustomStringConvertible>(text: T, isSelected: Bool) {
		self.valueLabel.text = text.description
		self.valueLabel.textColor = isSelected ? ColorsResources.selectedValColor :
		ColorsResources.disabledColor
	}

	private func setupView() {
		self.contentView.addSubview(self.valueLabel)

		self.valueLabel.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
	}
}
