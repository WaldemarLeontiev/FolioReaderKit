//
//  FolioReaderSearchResultsFooterCell.swift
//  FolioReaderKit
//
//  Created by Waldemar Leontiev on 06.07.2021.
//

import UIKit

class FolioReaderSearchResultsFooterCell: UITableViewCell {
    static let cellId = "FolioReaderSearchResultsFooterCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
        self.updateUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    var resultsCount: Int = 0 {
        didSet {
            self.updateUI()
        }
    }
    
    // MARK: - UI objects
    private lazy var resultLabel = self.makeResultLabel()
}

// MARK: - UI
extension FolioReaderSearchResultsFooterCell {
    private func setupUI() {
        selectionStyle = .none
        let titleLabel = self.makeTitleLabel()
        contentView.addSubview(titleLabel)
        contentView.addSubview(self.resultLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            self.resultLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            self.resultLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            self.resultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Constructors
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Search Completed"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }
    private func makeResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }
    
    // MARK: Actions
    private func updateUI() {
        switch self.resultsCount {
        case 0:
            self.resultLabel.text = "No matches found"
        case 1:
            self.resultLabel.text = "1 match found"
        default:
            self.resultLabel.text = "\(self.resultsCount) matches found"
        }
    }
}
