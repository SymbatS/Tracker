import UIKit

final class EmojiCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EmojiCollectionViewDelegate?
    
    private var selectedIndex: IndexPath?
    private let emojiList = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                             "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                             "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 24, left: 2, bottom: 24, right: 2)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
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
        collectionView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func selectEmoji(_ emoji: String) {
        guard let index = emojiList.firstIndex(of: emoji) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        selectedIndex = indexPath
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        
        let emoji = emojiList[indexPath.item]
        cell.setEmoji(emoji)
        cell.setSelected(indexPath == selectedIndex)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 6
        let horizontalSpacing: CGFloat = 5
        let insets: CGFloat = 2 * 2
        
        let totalSpacing = (itemsPerRow - 1) * horizontalSpacing + insets
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let selectedEmoji = emojiList[indexPath.item]
        delegate?.didSelectEmoji(selectedEmoji)
        collectionView.reloadData()
    }
}

protocol EmojiCollectionViewDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}
