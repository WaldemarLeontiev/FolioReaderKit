//
//  FolioReaderSearchResultCell.swift
//  FolioReaderKit
//
//  Created by Waldemar Leontiev on 05.07.2021.
//

import UIKit

class FolioReaderSearchResultCell: UITableViewCell {
    static let cellId = "FolioReaderSearchResultCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    var searchResult: SearchResult? {
        didSet {
            self.updateUI()
        }
    }
    
    // MARK: - UI objects
    private lazy var titleLabel = self.makeTitleLabel()
    private lazy var resultLabel = self.makeResultLabel()
}

// MARK: - UI
extension FolioReaderSearchResultCell {
    private func setupUI() {
        selectionStyle = .none
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.resultLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            self.titleLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.resultLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            self.resultLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16),
            self.resultLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            self.resultLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Constructors
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }
    private func makeResultLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }
    
    // MARK: Actions
    private func updateUI() {
        guard let searchResult = self.searchResult else {
            self.titleLabel.text = nil
            self.resultLabel.text = nil
            return
        }
        self.titleLabel.text = self.searchResult?.chapterName ?? "---"
        var preContent = self.cleanHtml(searchResult.contentPre)
        if let startIndex = preContent.index(preContent.endIndex, offsetBy: -50, limitedBy: preContent.startIndex) {
            preContent = String(preContent[startIndex...])
        }
        preContent = self.cleanStart(preContent)
        var postContent = self.cleanHtml(searchResult.contentPost)
        postContent = self.cleanEnd(postContent)
        let string = preContent + searchResult.content + postContent
        let attrString = NSMutableAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)])
        attrString.setAttributes([.font: UIFont.systemFont(ofSize: 15, weight: .bold)], range: NSRange(location: preContent.count, length: searchResult.content.count))
        self.resultLabel.attributedText = attrString
    }
    private func cleanHtml(_ html: String) -> String {
        guard let tagsRegex = try? NSRegularExpression(pattern: "(<[^>]*>)|(&[#\\w]*;)|(\\s)|(\\A[^<]*>)|(<[^>]*\\Z)", options: []),
              let spacesRegex = try? NSRegularExpression(pattern: "  +", options: []) else {
            return html
        }
        var cleanHtml = tagsRegex.stringByReplacingMatches(in: html, options: [], range: NSRange(location: 0, length: html.count), withTemplate: " ")
        cleanHtml = spacesRegex.stringByReplacingMatches(in: cleanHtml, options: [], range: NSRange(location: 0, length: cleanHtml.count), withTemplate: " ")
        return cleanHtml
    }
    private func cleanStart(_ string: String) -> String {
        guard let firstWordRegex = try? NSRegularExpression(pattern: "\\A\\w* ", options: []) else {
            return string
        }
        return firstWordRegex.stringByReplacingMatches(in: string, options: [], range: NSRange(location: 0, length: string.count), withTemplate: "")
    }
    private func cleanEnd(_ string: String) -> String {
        guard let lastWordRegex = try? NSRegularExpression(pattern: " \\w*\\Z", options: []) else {
            return string
        }
        return lastWordRegex.stringByReplacingMatches(in: string, options: [], range: NSRange(location: 0, length: string.count), withTemplate: "")
    }
}
