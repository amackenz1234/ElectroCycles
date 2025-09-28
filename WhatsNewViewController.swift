import UIKit

final class WhatsNewViewController: UIViewController {

    private let version: String
    var onViewUpdates: (() -> Void)?

    init(version: String) {
        self.version = version
        super.init(nibName: nil, bundle: nil)
        self.title = "What’s New"
        if #available(iOS 15.0, *) {
            self.sheetPresentationController?.detents = [.medium(), .large()]
            self.sheetPresentationController?.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        let closeButton = UIButton(type: .system)
        closeButton.configuration = .filled()
        closeButton.configuration?.title = "Got it"
        closeButton.configuration?.image = UIImage(systemName: "checkmark")
        closeButton.configuration?.imagePadding = 6
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "What’s New in \(version) (Beta)"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = """
• Evoque Atom product now has selectable battery options:
  – 72V 30Ah Lithium ($3,699)
  – 72V 35Ah Lead Acid ($2,699)
• Catalog simplified to a single product: Evoque Atom.
• Product images: Evoque Atom now uses an app asset image.
• Home UX tweaks:
  – “See All” hides when only one product is available.
  – “Browse Bikes” opens the Atom detail directly.
• Version bump to 1.1 (2).

What to test:
• Switch battery options on the Atom detail and verify price updates.
• Add to Cart from detail; verify cart badge/count and checkout totals.
• Use “Browse Bikes” from Home; confirm it opens the Atom detail.
• Confirm the Home Products card shows only Atom and hides “See All”.
• Verify the Evoque Atom image appears in list, detail, and cart.
• Open Settings → Updates to view this note.
"""
        bodyLabel.font = UIFont.preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0

        let viewUpdatesButton = UIButton(type: .system)
        viewUpdatesButton.configuration = .bordered()
        viewUpdatesButton.configuration?.title = "View Updates"
        viewUpdatesButton.configuration?.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        viewUpdatesButton.configuration?.imagePadding = 6
        viewUpdatesButton.addTarget(self, action: #selector(viewUpdatesTapped), for: .touchUpInside)
        viewUpdatesButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, viewUpdatesButton, closeButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func viewUpdatesTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onViewUpdates?()
        }
    }
}

/// Legacy What's New view controller kept for reference.
public class WhatsNewLegacyViewController: UIViewController {

    // MARK: - Public Properties

    /// The title displayed at the top of the view.
    public var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }

    /// The main content text describing what's new.
    public var contentText: String? {
        didSet {
            contentLabel.text = contentText
        }
    }

    /// The text of the button to dismiss the view controller.
    public var dismissButtonText: String = "Done" {
        didSet {
            dismissButton.setTitle(dismissButtonText, for: .normal)
        }
    }
    
    var onViewUpdates: (() -> Void)?

    // MARK: - Private UI Elements

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let dismissButton = UIButton(type: .system)

    private let contentStack = UIStackView()

    // MARK: - Init

    public init(title: String? = "What's New", content: String? = nil, dismissButtonText: String = "Done") {
        self.titleText = title
        self.contentText = content
        self.dismissButtonText = dismissButtonText
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            // Use sheetPresentationController if available for better sheet style
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = UIColor.systemBackground

        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentStack)

        // Title Label
        titleLabel.text = titleText
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true

        let headerImage = UIImageView()
        if let img = UIImage(named: "evoque_atom") {
            headerImage.image = img
            headerImage.contentMode = .scaleAspectFit
        } else {
            headerImage.image = UIImage(systemName: "bolt.circle.fill")
            headerImage.tintColor = .systemYellow
            headerImage.contentMode = .scaleAspectFit
        }
        headerImage.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let summaryLabel = UILabel()
        summaryLabel.text = "Evoque Atom gets selectable battery options and a streamlined single-product experience. Improved home navigation and visuals round out this beta."
        summaryLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 0

        // Content Label
        contentLabel.text = contentText
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.adjustsFontForContentSizeCategory = true

        // Add View Updates Button
        let viewUpdatesButton = UIButton(type: .system)
        viewUpdatesButton.configuration = .bordered()
        viewUpdatesButton.configuration?.title = "View Updates"
        viewUpdatesButton.configuration?.image = UIImage(systemName: "list.bullet.rectangle.portrait")
        viewUpdatesButton.configuration?.imagePadding = 6
        viewUpdatesButton.addTarget(self, action: #selector(viewUpdatesTapped), for: .touchUpInside)
        viewUpdatesButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // Dismiss Button
        dismissButton.setTitle(dismissButtonText, for: .normal)
        dismissButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        // Replace contentStack's arrangedSubviews with titleLabel, headerImage, summaryLabel, contentLabel, viewUpdatesButton, dismissButton
        contentStack.arrangedSubviews.forEach { contentStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(headerImage)
        contentStack.addArrangedSubview(summaryLabel)
        contentStack.addArrangedSubview(contentLabel)
        contentStack.addArrangedSubview(viewUpdatesButton)
        contentStack.addArrangedSubview(dismissButton)
    }

    private func setupConstraints() {
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20),

            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func viewUpdatesTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onViewUpdates?()
        }
    }
}

private extension UIFont {
    func bold() -> UIFont {
        return with(traits: .traitBold)
    }

    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
