import UIKit

internal final class ValueCollectionViewCell: UICollectionViewCell {

	private let valueLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
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

		let size = isSelected ? TextSizeResources.moreBig : TextSizeResources.big
		self.valueLabel.font = UIFont(name: FontsResources.segoe, size: size)

		self.valueLabel.textColor = isSelected ? ColorsResources.selectedValColor :
		ColorsResources.disabledColor
	}

	private func setupView() {
		self.contentView.addSubview(self.valueLabel)

		self.valueLabel.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
	}
}
