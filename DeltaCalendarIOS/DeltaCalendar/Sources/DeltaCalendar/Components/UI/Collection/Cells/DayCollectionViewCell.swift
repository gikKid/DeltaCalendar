import UIKit

internal final class DayCollectionViewCell: UICollectionViewCell {

	private let centerLabel: UILabel = {
		let size = TextSizeResources.mid

		$0.textAlignment = .center
		$0.font = UIFont.systemFont(ofSize: size)
		return $0
	}(UILabel())

	private let btmLabel: UILabel = {
		let size = TextSizeResources.small

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

    func configure(with data: DayItem, colors: Colors) {

		self.centerLabel.text = data.data.title

		self.btmLabel.text = data.data.description
        self.btmLabel.textColor = data.isSelected ? colors.background : colors.main

		self.isUserInteractionEnabled = !data.isDisabled

		guard !data.isDisabled else {
			self.contentView.backgroundColor = .clear
            self.centerLabel.textColor = colors.secondaryText
			return
		}

        self.centerLabel.textColor = data.isSelected ? colors.background : colors.text

        self.contentView.backgroundColor = data.isSelected ? colors.main : .clear
	}
}

private extension DayCollectionViewCell {
	func setupView() {
		self.contentView.backgroundColor = .clear
		self.contentView.layer.cornerRadius = RadiusResources.day

		self.contentView.addSubview(self.centerLabel)
		self.contentView.addSubview(self.btmLabel)

		self.setConstraints()
	}

	func setConstraints() {
		self.centerLabel.snp.makeConstraints {
			$0.edges.equalTo(self.contentView).inset(SpaceResources.moreMid)
		}

		self.btmLabel.snp.makeConstraints {
			$0.top.equalTo(self.centerLabel.snp.bottom)
			$0.bottom.equalTo(self.contentView)
			$0.leading.trailing.equalTo(self.contentView).inset(SpaceResources.small)
		}
	}
}
