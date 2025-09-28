//
//  WhatsNewViewController.swift
//  Electro Cycles
//
//  Created by Assistant on 2025-09-27.
//

import UIKit

final class WhatsNewViewController: UIViewController {
    
    private let version: String
    var onViewUpdates: (() -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    init(version: String) {
        self.version = version
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create header
        let headerLabel = UILabel()
        headerLabel.text = "What's New"
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let versionLabel = UILabel()
        versionLabel.text = "Version \(version)"
        versionLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        versionLabel.textColor = .systemBlue
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create feature list
        let featuresStack = createFeaturesStack()
        
        // Create buttons
        let viewUpdatesButton = UIButton(type: .system)
        viewUpdatesButton.setTitle("View Updates", for: .normal)
        viewUpdatesButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        viewUpdatesButton.backgroundColor = .systemBlue
        viewUpdatesButton.setTitleColor(.white, for: .normal)
        viewUpdatesButton.layer.cornerRadius = 12
        viewUpdatesButton.translatesAutoresizingMaskIntoConstraints = false
        viewUpdatesButton.addTarget(self, action: #selector(viewUpdatesButtonTapped), for: .touchUpInside)
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Add all views to content view
        contentView.addSubview(headerLabel)
        contentView.addSubview(versionLabel)
        contentView.addSubview(featuresStack)
        contentView.addSubview(viewUpdatesButton)
        contentView.addSubview(continueButton)
        
        // Store views for constraints
        self.headerLabel = headerLabel
        self.versionLabel = versionLabel
        self.featuresStack = featuresStack
        self.viewUpdatesButton = viewUpdatesButton
        self.continueButton = continueButton
    }
    
    private var headerLabel: UILabel!
    private var versionLabel: UILabel!
    private var featuresStack: UIStackView!
    private var viewUpdatesButton: UIButton!
    private var continueButton: UIButton!
    
    private func createFeaturesStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Sample features - you can customize these based on your app's actual updates
        let features = [
            ("bolt.fill", "Enhanced Performance", "Faster loading times and improved responsiveness throughout the app."),
            ("bell.fill", "Smart Notifications", "Get notified about new bike arrivals, sales, and maintenance reminders."),
            ("heart.fill", "Improved Favorites", "Better organization and syncing of your favorite bikes across devices."),
            ("gearshape.fill", "New Settings", "More customization options and improved notification controls.")
        ]
        
        for (iconName, title, description) in features {
            let featureView = createFeatureView(iconName: iconName, title: title, description: description)
            stack.addArrangedSubview(featureView)
        }
        
        return stack
    }
    
    private func createFeatureView(iconName: String, title: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header constraints
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            versionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Features stack constraints
            featuresStack.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 40),
            featuresStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featuresStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Buttons constraints
            viewUpdatesButton.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 40),
            viewUpdatesButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            viewUpdatesButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            viewUpdatesButton.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.topAnchor.constraint(equalTo: viewUpdatesButton.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func viewUpdatesButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onViewUpdates?()
        }
    }
    
    @objc private func continueButtonTapped() {
        dismiss(animated: true)
    }
}