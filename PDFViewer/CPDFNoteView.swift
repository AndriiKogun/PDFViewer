//
//  CPDFNoteView.swift
//  PDFViewer
//
//  Created by Andrii on 25.12.2019.
//  Copyright © 2019 Andrii. All rights reserved.
//

import UIKit


protocol CPDFNoteViewDelegate: class {
    
    func sendAction(_ sender: UIButton)
}


class CPDFNoteView: UIView {

    weak var delegate: CPDFNoteViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.text = "WRITING NOTE FOR PAGE 1"
        titleLabel.font = .systemFont(ofSize: 10)
        return titleLabel
    }()
    
    private lazy var sendButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.tintColor = .gray
        closeButton.setImage(UIImage(named: "PDF_send_icon"), for: .normal)
        closeButton.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        return closeButton
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.keyboardAppearance = .dark
        textView.isScrollEnabled = false
        textView.backgroundColor = .gray
        textView.tintColor = .white
        textView.layer.cornerRadius = 4
        textView.delegate = self
        return textView
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .black
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview()
        }
        
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.height.greaterThanOrEqualTo(48)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-50)
        }
        
        addSubview(sendButton)
        sendButton .snp.makeConstraints { (make) in
            make.centerY.equalTo(textView.snp.centerY)
            make.right.equalToSuperview().offset(-14)
        }
    }
    
    //MARK: - Actions
    @objc func sendAction(_ sender: UIButton) {
        delegate?.sendAction(sender)
    }
}

//MARK: - UITextViewDelegate
extension CPDFNoteView: UITextViewDelegate {
    
    
}
