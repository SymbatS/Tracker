import UIKit

final class DayCell: UITableViewCell {
    
    private let bgView = UIView()
    private let titleLabel = UILabel()
    private let daySwitch = UISwitch()
    private let separator = UIView()
    
    var switchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(day: String, isOn: Bool) {
        titleLabel.text = day
        daySwitch.onTintColor = .systemBlue
        daySwitch.isOn = isOn
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        
        contentView.layer.cornerRadius = 0
        contentView.layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daySwitch)
        daySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switchChanged?(sender.isOn)
    }
}
