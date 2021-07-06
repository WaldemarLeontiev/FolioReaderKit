//
//  FolioReaderSearchSearchingCell.swift
//  FolioReaderKit
//
//  Created by Waldemar Leontiev on 06.07.2021.
//

import UIKit

class FolioReaderSearchSearchingCell: UITableViewCell {
    static let cellId = "FolioReaderSearchSearchingCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI objects
    private lazy var activityIndicatorView = self.makeActivityIndicatorView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicatorView.startAnimating()
    }
}

// MARK: - UI
extension FolioReaderSearchSearchingCell {
    private func setupUI() {
        selectionStyle = .none
        let containerView = self.makeContainerView()
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Constructors
    private func makeContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let searchingLabel = self.makeSearchingLabel()
        view.addSubview(activityIndicatorView)
        view.addSubview(searchingLabel)
        NSLayoutConstraint.activate([
            activityIndicatorView.leftAnchor.constraint(equalTo: view.leftAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchingLabel.leftAnchor.constraint(equalTo: activityIndicatorView.rightAnchor, constant: 8),
            searchingLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }
    private func makeActivityIndicatorView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }
    private func makeSearchingLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Searching..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }
}
