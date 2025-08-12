import UIKit

final class TrackerCell: UICollectionViewCell {
    
    private let cardView = UIView()
    private let emojiBackgroundView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let footerView = UIView()
    private let countLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    
    var onToggleDone: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        nameLabel.text = nil
        countLabel.text = nil
        doneButton.setImage(nil, for: .normal)
        doneButton.isEnabled = true
        doneButton.alpha = 1
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        emojiBackgroundView.backgroundColor = UIColor { tc in
            tc.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.22)
            : UIColor.white.withAlphaComponent(0.30)
        }
        
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.textAlignment = .center
        
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        
        footerView.backgroundColor = .clear
        
        countLabel.font = .systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = .label
        doneButton.layer.cornerRadius = 17
        doneButton.clipsToBounds = true
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        contentView.addSubview(cardView)
        contentView.addSubview(footerView)
        
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
        footerView.addSubview(countLabel)
        footerView.addSubview(doneButton)
        
        [cardView, emojiBackgroundView, emojiLabel, nameLabel, footerView, countLabel, doneButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            footerView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 4),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            countLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12),
            
            doneButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -12),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func didTapDone() { onToggleDone?() }
    
    func configure(with tracker: Tracker, isDone: Bool, count: Int, isFuture: Bool) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        cardView.backgroundColor = tracker.color
        
        countLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "Количество выполненных дней"),
            count
        )
        
        let symbolName = isDone ? "checkmark" : "plus"
        doneButton.setImage(UIImage(systemName: symbolName), for: .normal)
        
        doneButton.isEnabled = !isFuture
        doneButton.alpha = isFuture ? 0.3 : 1.0
        
        if isDone {
            doneButton.backgroundColor = tracker.color.withAlphaComponent(0.30)
        } else {
            doneButton.backgroundColor = tracker.color
        }
        doneButton.tintColor = .white
    }
}
