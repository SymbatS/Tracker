import UIKit
final class StatsCardCell: UITableViewCell {
    
    private let container = GradientView()
    private let cardView  = UIView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let cornerRadius: CGFloat = 16
    private var borderWidth: CGFloat  = 3
    
    private var topC: NSLayoutConstraint!
    private var leadC: NSLayoutConstraint!
    private var trailC: NSLayoutConstraint!
    private var bottomC: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        container.layer.cornerRadius = cornerRadius
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = cornerRadius - borderWidth
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardView)
        
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        [valueLabel, titleLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; cardView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 90),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: valueLabel.bottomAnchor, constant: 8),
        ])
        
        topC    = cardView.topAnchor.constraint(equalTo: container.topAnchor, constant: borderWidth)
        leadC   = cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: borderWidth)
        trailC  = cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -borderWidth)
        bottomC = cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -borderWidth)
        NSLayoutConstraint.activate([topC, leadC, trailC, bottomC])
    }
    
    func configure(title: String, value: String, gradientColors: [UIColor], width: CGFloat = 3) {
        valueLabel.text = value
        titleLabel.text = title
        
        container.colors = gradientColors
        container.locations = [0.0, 0.526, 1.0]
        container.startPoint = CGPoint(x: 1, y: 0.5)
        container.endPoint   = CGPoint(x: 0, y: 0.5)
        
        if abs(width - borderWidth) > .ulpOfOne {
            borderWidth = width
            topC.constant = width; leadC.constant = width
            trailC.constant = -width; bottomC.constant = -width
            cardView.layer.cornerRadius = cornerRadius - width
            layoutIfNeeded()
        }
    }
}
