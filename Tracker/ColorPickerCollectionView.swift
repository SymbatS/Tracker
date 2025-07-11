import UIKit

protocol ColorPickerCollectionViewDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

final class ColorPickerCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: ColorPickerCollectionViewDelegate?
    private var selectedIndex: IndexPath?
    
    private let colorHexList: [String] = [
        "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
        "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
        "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 18, bottom: 12, right: 18)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorHexList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        
        let hex = colorHexList[indexPath.item]
        if let color = UIColor(hex: hex) {
            cell.setColor(color)
            cell.setSelected(indexPath == selectedIndex)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 8
        let insets: CGFloat = 18 * 2
        let totalSpacing = (itemsPerRow - 1) * spacing + insets
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        collectionView.reloadData()
        
        let hex = colorHexList[indexPath.item]
        if let color = UIColor(hex: hex) {
            delegate?.didSelectColor(color)
        }
    }
}

// MARK: - UIColor Hex Extension

extension UIColor {
    convenience init?(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        guard hexFormatted.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
