//
//  FolioReaderSearch.swift
//  FolioReaderKit
//
//  Created by Waldemar Leontiev on 02.07.2021.
//

import UIKit

class FolioReaderSearch: UIViewController {
    init(readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    let readerConfig: FolioReaderConfig
    var searchHandler: ((String, @escaping ([SearchResult]) -> Void) -> Void)?
    var updateHandler: (() -> Void)?
    var jumpHandler: ((SearchResult) -> Void)?
    
    // MARK: - UI objects
    private lazy var textField = self.makeTextField()
    private lazy var resultsTableView = self.makeResultsTableView()
    
    // MARK: - Private stuff
    private lazy var resultsState: ResultsState = initialState {
        didSet {
            self.resultsTableView.reloadData()
        }
    }
    
    private enum ResultsState {
        case empty
        case searching
        case showing([SearchResult])
    }
    
    private var initialState: ResultsState {
        if let results = Search.results {
            return .showing(results)
        } else {
            return .empty
        }
    }
}

// MARK: - UIViewController overrides
extension FolioReaderSearch {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.textField.becomeFirstResponder()
    }
}

// MARK: - UI actions
extension FolioReaderSearch {
    @objc private func handleCloseButtonTap() {
        self.dismiss()
    }
}

// MARK: - UI
extension FolioReaderSearch {
    private func setupUI() {
        self.view.backgroundColor = .white
        let closeButton = self.makeCloseButton()
        self.view.addSubview(closeButton)
        self.view.addSubview(self.textField)
        self.view.addSubview(self.resultsTableView)
        NSLayoutConstraint.activate([
            closeButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            closeButton.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.textField.leftAnchor.constraint(equalTo: closeButton.rightAnchor),
            self.textField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8),
            self.textField.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 24),
            self.resultsTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.resultsTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.resultsTableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            self.resultsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    // MARK: Constructors
    private func makeTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = Search.text
        textField.placeholder = "Type a word"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .always
        let padding = 8
        let size = 20
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = UIImage(readerImageNamed: "icon-navbar-search")?.imageTintColor(.gray)?.withRenderingMode(.alwaysOriginal)
        outerView.addSubview(iconView)
        textField.leftView = outerView
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.delegate = self
        return textField
    }
    private func makeCloseButton() -> UIButton {
        let closeImage = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint(withConfiguration: readerConfig)
        let closeButton = UIButton(type: .custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(closeImage, for: .normal)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 48),
            closeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        closeButton.addTarget(self, action: #selector(self.handleCloseButtonTap), for: .touchUpInside)
        return closeButton
    }
    private func makeResultsTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect(), style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FolioReaderSearchResultCell.self, forCellReuseIdentifier: FolioReaderSearchResultCell.cellId)
        tableView.register(FolioReaderSearchResultsFooterCell.self, forCellReuseIdentifier: FolioReaderSearchResultsFooterCell.cellId)
        tableView.register(FolioReaderSearchSearchingCell.self, forCellReuseIdentifier: FolioReaderSearchSearchingCell.cellId)
        tableView.estimatedRowHeight = 96
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }
}

// MARK: - UITextFieldDelegate
extension FolioReaderSearch: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let rangeInOldText = Range(range, in: oldText) else {
            return true
        }
        let text = oldText.replacingCharacters(in: rangeInOldText, with: string)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard text == self?.textField.text else {
                return
            }
            if text.count <= 2 {
                print("Search text \"\(text)\" is too short, cleaning the list")
                self?.resultsState = .empty
            } else {
                print("Searching \"\(text)\"")
                self?.resultsState = .searching
                self?.searchHandler?(text) { [weak self] results in
                    guard text == self?.textField.text else {
                        print("Text changed after search complete, the search is ignored")
                        return
                    }
                    print("Search \"\(text)\": \(results.count) results")
                    Search.text = text
                    Search.results = results
                    self?.updateHandler?()
                    self?.resultsState = .showing(results)
                }
            }
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != Search.text {
            if textField.text == nil || textField.text!.isEmpty {
                Search.text = nil
                Search.results = nil
                self.updateHandler?()
                self.resultsState = .empty
            } else {
                let text = textField.text!
                print("Searching \"\(text)\"")
                self.resultsState = .searching
                self.searchHandler?(text) { [weak self] results in
                    guard text == self?.textField.text else {
                        print("Text changed after search complete, the search is ignored")
                        return
                    }
                    print("Search \"\(text)\": \(results.count) results")
                    Search.text = text
                    Search.results = results
                    self?.updateHandler?()
                    self?.resultsState = .showing(results)
                }
            }
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        Search.text = nil
        Search.results = nil
        self.updateHandler?()
        self.resultsState = .empty
        return true
    }
}

// MARK: - UITableViewDataSource
extension FolioReaderSearch: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.resultsState {
        case .empty:
            return 0
        case .searching:
            return 1
        case .showing(let results):
            return results.count + 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.resultsState {
        case .empty:
            return UITableViewCell()
        case .searching:
            return tableView.dequeueReusableCell(withIdentifier: FolioReaderSearchSearchingCell.cellId, for: indexPath)
        case .showing(let results):
            if indexPath.row < results.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: FolioReaderSearchResultCell.cellId, for: indexPath) as! FolioReaderSearchResultCell
                cell.searchResult = results[indexPath.row]
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: FolioReaderSearchResultsFooterCell.cellId, for: indexPath) as! FolioReaderSearchResultsFooterCell
                cell.resultsCount = results.count
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension FolioReaderSearch: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.resultsState {
        case .empty, .searching:
            return
        case .showing(let results):
            if indexPath.row < results.count {
                self.jumpHandler?(results[indexPath.row])
                self.dismiss()
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textField.resignFirstResponder()
    }
}
