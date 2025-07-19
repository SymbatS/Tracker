import UIKit

final class ColorCell: UICollectionViewCell {
    
    private let colorView = UIView()
    private let selectionRing = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true
        contentView.addSubview(colorView)
        
        selectionRing.translatesAutoresizingMaskIntoConstraints = false
        selectionRing.layer.cornerRadius = 12
        selectionRing.layer.borderWidth = 3
        selectionRing.isUserInteractionEnabled = false
        selectionRing.isHidden = true
        contentView.addSubview(selectionRing)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            
            selectionRing.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionRing.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionRing.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionRing.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
        selectionRing.layer.borderColor = color.cgColor
    }
    
    func setSelected(_ selected: Bool) {
        selectionRing.isHidden = !selected
    }
}
