import UIKit

final class TrackersViewController: UIViewController {
    
    private let largeTitle = UILabel()
    private let plusButton = UIButton()
    private let datePicker = UIDatePicker()
    private let searchField = UITextField()
    private let image = UIImageView()
    private let smallTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews(largeTitle, plusButton, datePicker, searchField, image, smallTitle)
        [largeTitle, plusButton, datePicker, searchField, image, smallTitle].disableAutoResizingMasks()
        
        plusButton.setImage(UIImage(named: "Plus"), for: .normal)
        
        largeTitle.text = "Трекеры"
        largeTitle.font = .systemFont(ofSize: 34, weight: .bold)
        largeTitle.textColor = .black
        
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .automatic
        
        searchField.placeholder = "Поиск"
        searchField.layer.cornerRadius = 10
        searchField.layer.masksToBounds = true
        searchField.backgroundColor =  UIColor(red: 118/255, green: 118/255, blue: 128/255, alpha: 0.12)
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        imageView.frame = CGRect(x: 8, y: 0, width: 15, height: 20)
        paddingView.addSubview(imageView)
        searchField.leftViewMode = .always
        searchField.leftView = paddingView
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        
        image.image = UIImage(named: "Star")
        
        smallTitle.text = "Что будем отслеживать?"
        smallTitle.font = .systemFont(ofSize: 12, weight: .regular)
        smallTitle.textColor = .black
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 1),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            plusButton.widthAnchor.constraint(equalToConstant: 42),
            plusButton.heightAnchor.constraint(equalToConstant: 42),
            
            datePicker.topAnchor.constraint(equalTo: guide.topAnchor, constant: 5),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            largeTitle.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 1),
            largeTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchField.topAnchor.constraint(equalTo: largeTitle.bottomAnchor, constant: 7),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            
            image.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 80),
            image.heightAnchor.constraint(equalToConstant: 80),
            
            smallTitle.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            smallTitle.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ])

    }

}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension Array where Element: UIView {
    func disableAutoResizingMasks() {
        forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
}
