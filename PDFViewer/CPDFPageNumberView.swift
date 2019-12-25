//
//  CPDFPageNumberView.swift
//  Cadence
//
//  Created by Andrii on 11/12/18.
//  Copyright © 2018 Cadence. All rights reserved.
//

import UIKit

class CPDFPageNumberView: UIView {
    private var workItem: DispatchWorkItem!
    private var viewIsAnimating = false
    
    private let numberLabel: UILabel = {
        let numberLabel = UILabel()
        numberLabel.font = .systemFont(ofSize: 12, weight: .regular)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        return numberLabel
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureUI()
        backgroundColor = .black
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(currentPageNumber: Int, totalPageNumber: Int) {
        numberLabel.text = String(currentPageNumber) + "/" + String(totalPageNumber)
        show()
    }

    func show() {
        workItem.cancel()
        hideDelayTask()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: workItem)
        
        if !viewIsAnimating {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
                self.viewIsAnimating = true
                self.alpha = 1
            }) {(completion) in
                self.viewIsAnimating = false
            }
        }
    }
    
    func hide() {
        if !viewIsAnimating {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
                self.viewIsAnimating = true
                self.alpha = 0
            }) {(completion) in
                self.viewIsAnimating = false
            }
        }
    }

    private func hideDelayTask() {
        workItem = DispatchWorkItem {
            self.hide()
        }
    }

    private func configureUI() {
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        hideDelayTask()
    }
}
