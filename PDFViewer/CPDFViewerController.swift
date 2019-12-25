//
//  CPDFViewerController.swift
//  PDFViewer
//
//  Created by Andrii on 23.12.2019.
//  Copyright © 2019 Andrii. All rights reserved.
//

import UIKit

class CPDFViewerController: UIViewController {
    
    private lazy var readerViewController: CPDFReaderViewController = {
        let readerViewController = CPDFReaderViewController(with: .presentation, materialItem: DigitalPrintItem())
        readerViewController.delegate = self
        return readerViewController
    }()
    
    private var tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.isTranslucent = false
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        
        let viewTabBarItem = UITabBarItem(title: "View",
                                          image: UIImage(named: "PDF_visible_unselected_icon"),
                                          selectedImage: UIImage(named: "PDF_visible_selected_icon"))
        
        let notesTabBarItem = UITabBarItem(title: "Notes",
                                           image: UIImage(named: "PDF_notes_unselected_icon"),
                                           selectedImage: UIImage(named: "PDF_notes_selected_icon"))

        let saveTabBarItem = UITabBarItem(title: "Saved",
                                          image: UIImage(named: "PDF_save_unselected_icon"),
                                          selectedImage: UIImage(named: "PDF_save_selected_icon"))

        tabBar.items = [viewTabBarItem, notesTabBarItem, saveTabBarItem]

        tabBar.selectedItem = viewTabBarItem
        return tabBar
    }()

    private var containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupLayout()
    }
    
    private func setupLayout() {
        addChild(readerViewController)
        view.addSubview(readerViewController.view)
        readerViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}

//MARK: - CPDFReaderViewControllerDelegate
extension CPDFViewerController: CPDFReaderViewControllerDelegate {
    func didTapGesture(_ sender: UITapGestureRecognizer) {
        tabBar.isHidden = !tabBar.isHidden
    }
}



