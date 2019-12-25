//
//  CPDFViewHeaderView.swift
//  PDF
//
//  Created by Andrii on 11/7/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit

protocol CPDFViewHeaderViewDelegate: class {
    
    func dissmissAction(_ sender: UIButton)
    func writeNoteAction(_ sender: UIButton)
    func saveAction(_ sender: UIButton)
    func moreAction(_ sender: UIButton)
}

class CPDFViewHeaderView: UIView {
    
    weak var delegate: CPDFViewHeaderViewDelegate?
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.backgroundColor = .black
        closeButton.layer.cornerRadius = 4
        closeButton.setImage(UIImage(named: "PDF_close_icon"), for: .normal)
        closeButton.addTarget(self, action: #selector(dissmisAction(_:)), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var noteButton: UIButton = {
        let noteButton = UIButton(type: .custom)
        noteButton.backgroundColor = .black
        noteButton.layer.cornerRadius = 4
        noteButton.setImage(UIImage(named: "PDF_write_note_icon"), for: .normal)
        noteButton.addTarget(self, action: #selector(writeNoteAction(_:)), for: .touchUpInside)
        return noteButton
    }()
    
    private lazy var savedButton: UIButton = {
        let savedButton = UIButton(type: .custom)
        savedButton.backgroundColor = .black
        savedButton.layer.cornerRadius = 4
        savedButton.setImage(UIImage(named: "PDF_saved_icon"), for: .normal)
        savedButton.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
        return savedButton
    }()
    
    private lazy var moreButton: UIButton = {
        let moreButton = UIButton(type: .custom)
        moreButton.backgroundColor = .black
        moreButton.layer.cornerRadius = 4
        moreButton.setImage(UIImage(named: "PDF_saved_icon"), for: .normal)
        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        return moreButton
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.left.equalToSuperview().offset(16)
        }
        
        addSubview(moreButton)
        moreButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.right.equalToSuperview().offset(-16)
        }
        
        addSubview(savedButton)
        savedButton .snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.right.equalTo(moreButton.snp.left).offset(-12)
        }

        addSubview(noteButton)
        noteButton .snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.right.equalTo(savedButton.snp.left).offset(-12)
        }
    }
    
    //MARK: - Actions
    @objc func dissmisAction(_ sender: UIButton) {
        delegate?.dissmissAction(sender)
    }
    
    @objc func writeNoteAction(_ sender: UIButton) {
        delegate?.writeNoteAction(sender)
    }
    
    @objc func saveAction(_ sender: UIButton) {
        delegate?.saveAction(sender)
    }
    
    @objc func moreAction(_ sender: UIButton) {
        delegate?.moreAction(sender)
    }
}

