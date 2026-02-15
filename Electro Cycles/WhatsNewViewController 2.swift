// Refactored: This modern variant avoids conflicting with the primary WhatsNewViewController.
import UIKit

final class WhatsNewModernViewController: UIViewController {

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

