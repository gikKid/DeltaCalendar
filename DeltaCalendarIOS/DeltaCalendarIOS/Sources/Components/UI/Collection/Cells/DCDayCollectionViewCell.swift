import UIKit

final class DCDayCollectionViewCell: UICollectionViewCell {

	private let centerLabel: UILabel = {
		let size = DCTextSizeResources.mid

		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont(name: DCFontsResources.segoe, size: size)
		return label
	}()
	private let btmLabel: UILabel = {
		let size = DCTextSizeResources.small

		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont(name: DCFontsResources.segoe, size: size)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with data: DCalendarDayItem) {

		self.centerLabel.text = data.data.title

		self.btmLabel.text = data.data.description
		self.btmLabel.textColor = data.isSelected ? data.colors.selectedBtmText :
		data.colors.btmText

		self.isUserInteractionEnabled = !data.isDisabled

		guard !data.isDisabled else {
			self.contentView.backgroundColor = .clear
			self.centerLabel.textColor = DCColorsResources.disabledColor
			return
		}

		self.centerLabel.textColor = data.isSelected ? data.colors.centerTextSelected :
		data.colors.centerText

		self.contentView.backgroundColor = data.isSelected ? data.colors.selectedBack : .clear
	}
}

private extension DCDayCollectionViewCell {
	func setupView() {
		self.contentView.backgroundColor = .clear
		self.contentView.layer.cornerRadius = DCRadiusResources.day

		self.contentView.addSubview(self.centerLabel)
		self.contentView.addSubview(self.btmLabel)

		self.setConstraints()
	}

	func setConstraints() {
		self.centerLabel.snp.makeConstraints {
			$0.edges.equalTo(self.contentView).inset(DCSpaceResources.moreMid)
		}

		self.btmLabel.snp.makeConstraints {
			$0.top.equalTo(self.centerLabel.snp.bottom)
			$0.bottom.equalTo(self.contentView)
			$0.leading.trailing.equalTo(self.contentView).inset(DCSpaceResources.small)
		}
	}
}
