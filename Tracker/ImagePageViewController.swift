import UIKit

final class ImagePageViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let textLabel = UILabel()
    
    init(imageName: String, labelText: String) {
        super.init(nibName: nil, bundle: nil)
        
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        textLabel.text = labelText
        textLabel.font = .systemFont(ofSize: 32, weight: .bold)
        textLabel.textAlignment = .center
        textLabel.textColor = .black
        textLabel.numberOfLines = 0
        textLabel.layer.cornerRadius = 12
        textLabel.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            textLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 76)
        ])
    }
}
