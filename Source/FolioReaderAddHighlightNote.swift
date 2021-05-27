//
//  FolioReaderAddHighlightNote.swift
//  FolioReaderKit
//
//  Created by ShuichiNagao on 2018/05/06.
//

import UIKit
import RealmSwift

class FolioReaderAddHighlightNote: UIViewController {

    var textView: UITextView!
    var highlightLabel: UILabel!
    var highlight: Highlight!
    var highlightSaved = false
    var isEditHighlight = false
    var resizedTextView = false
    var textViewBottomConstraint: NSLayoutConstraint!
    
    private var folioReader: FolioReader
    private var readerConfig: FolioReaderConfig
    
    init(withHighlight highlight: Highlight, folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.folioReader = folioReader
        self.highlight = highlight
        self.readerConfig = readerConfig
        
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCloseButton(withConfiguration: readerConfig)
        setupUI()
        configureNavBar()
        configureKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isEditHighlight {
            textView.becomeFirstResponder()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !highlightSaved && !isEditHighlight {
            guard let currentPage = folioReader.readerCenter?.currentPage else { return }
            currentPage.webView?.js("removeThisHighlight()")
        }
    }
    
    // MARK: - private methods
    private func setupUI() {
        view.backgroundColor = .white
        highlightLabel = UILabel()
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        highlightLabel.numberOfLines = 3
        highlightLabel.font = UIFont.systemFont(ofSize: 15)
        highlightLabel.text = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        view.addSubview(highlightLabel)
        NSLayoutConstraint.activate([
            highlightLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            highlightLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            highlightLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
        
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        if isEditHighlight {
             textView.text = highlight.noteForHighlight
        }
        view.addSubview(textView)
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: highlightLabel.bottomAnchor, constant: 20),
            textViewBottomConstraint
        ])
    }
    
    private func configureNavBar() {
        let navBackground = folioReader.isNight(self.readerConfig.nightModeNavBackground, self.readerConfig.daysModeNavBackground)
        let tintColor = readerConfig.tintColor
        let navText = folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
        
        let titleAttrs = [NSAttributedString.Key.foregroundColor: readerConfig.tintColor]
        let saveButton = UIBarButtonItem(title: readerConfig.localizedSave, style: .plain, target: self, action: #selector(saveNote(_:)))
        saveButton.setTitleTextAttributes(titleAttrs, for: UIControl.State())
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func configureKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        textViewBottomConstraint.constant = -keyboardFrame.height - 20
        view.layoutSubviews()
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
        textViewBottomConstraint.constant = -20
        view.layoutSubviews()
    }
    
    @objc private func saveNote(_ sender: UIBarButtonItem) {
        if !textView.text.isEmpty {
            if isEditHighlight {
                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
                realm.beginWrite()
                highlight.noteForHighlight = textView.text
                highlightSaved = true
                try! realm.commitWrite()
            } else {
                highlight.noteForHighlight = textView.text
                highlight.persist(withConfiguration: readerConfig)
                highlightSaved = true
            }
        }
        
        dismiss()
    }
}
