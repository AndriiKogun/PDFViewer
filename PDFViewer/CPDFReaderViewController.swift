//
//  CPDFReaderViewController.swift
//  PDF
//
//  Created by A K on 11/4/18.
//  Copyright © 2018 A K. All rights reserved.
//

import UIKit
import PDFKit
import SnapKit

@objc enum CPDFReaderStyleEnum: Int {
    case presentation
    case list
}

protocol CPDFReaderViewControllerDelegate: class {
    func didTapGesture(_ sender: UITapGestureRecognizer)
}

@available(iOS 11.0, *)
@objc class CPDFReaderViewController: UIViewController {
    
    weak var delegate: CPDFReaderViewControllerDelegate?
    
   //MARK: - Properties
    private lazy var noteView: CPDFNoteView = {
        let noteView = CPDFNoteView()
        noteView.isHidden = true
        noteView.delegate = self
        return noteView
    }()
    
    let toolBar = UIToolbar()

   private lazy var pdfView: PDFView = {
        let pdfView = PDFView()
//        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
//        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.backgroundColor = .clear
        pdfView.autoScales = true
        pdfView.delegate = self
        return pdfView
    }()
    
    private lazy var thumbnailView : PDFThumbnailView = {
        let thumbnailView = PDFThumbnailView()
        thumbnailView.backgroundColor = .black
        thumbnailView.pdfView = pdfView
        thumbnailView.layoutMode = .horizontal
        thumbnailView.thumbnailSize = CGSize(width: 22, height: 32)
        thumbnailView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return thumbnailView
    }()
    
    private lazy var headerView: CPDFViewHeaderView = {
        let headerView = CPDFViewHeaderView()
        headerView.backgroundColor = .clear
        headerView.delegate = self
        return headerView
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }()
    
//    private lazy var searchViewController: CPDFReaderSearchController = {
//        let searchViewController = CPDFReaderSearchController(with: pdfView.document, colorScheme: colorScheme)
//        searchViewController.modalPresentationStyle = .fullScreen
//        searchViewController.delegate = self
//        return searchViewController
//    }()
    
//    private lazy var progressView: CPDFProgressView = {
//        let progressView = CPDFProgressView()
//        progressView.contentColor = colorScheme
//        return progressView
//    }()

    private var isNavigationHidden = false

    private let style: CPDFReaderStyleEnum
    private let materialItem: DigitalPrintItem
    
    private var page: PDFPage!
    private let pageNumberView = CPDFPageNumberView()
    
//    private let storage = BPMainAppStorage()

    private var isLandscape = false
    private var isFullScreen = false
//    private var downloadProgressView: BPProgressView!
    
//    private let materialsManager = CAMaterialsManager()
    
    //MARK: - Init
    @objc init(with style: CPDFReaderStyleEnum, materialItem: DigitalPrintItem) {
        self.style = style
        self.materialItem = materialItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configurePDFView()
        addObservers()
        loadPDF()
        
        pdfView.addGestureRecognizer(tapGestureRecognizer)
        view.backgroundColor = .gray
    }
    
    override var prefersStatusBarHidden: Bool {
        return isLandscape
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    //MARK: - Notifications
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pdfViewPageChanged),
                                               name: Notification.Name.PDFViewPageChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onOrientationChange(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    //MARK: - UIKeyboardNotification
    @objc func keyboardWillShow(_ notification: Notification?) {
        if let userInfo = notification?.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect).size.height
            
            noteView.isHidden = false
            noteView.snp.updateConstraints { (update) in
                update.bottom.equalToSuperview().offset(-keyboardHeight)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification?) {
        noteView.snp.updateConstraints { (update) in
            update.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.noteView.isHidden = true
        }
    }
    
    //MARK: - Private Methods
    private func configureUI() {
        view.addSubview(pdfView)
        pdfView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.height.equalTo(56)
            make.top.equalTo(view.layoutMarginsGuide.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
//        view.addSubview(progressView)
//        progressView.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(42)
//            make.right.equalToSuperview().offset(-42)
//
//            if isIpad {
//                make.centerX.equalToSuperview()
//                make.width.equalTo(600)
//            }
//        }
        
        view.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints { (make) in
            make.height.equalTo(52)
            make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(-48)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        view.addSubview(pageNumberView)
        pageNumberView.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(58)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(thumbnailView.snp.top).offset(-8)
        }
        
        view.addSubview(noteView)
        noteView.snp.makeConstraints { (make) in
            make.left.equalTo(view.layoutMarginsGuide.snp.left).offset(-16)
            make.right.equalTo(view.layoutMarginsGuide.snp.right).offset(16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func configurePDFView() {
        switch style {
        case .presentation:
            pdfView.displayDirection = .horizontal
            pdfView.usePageViewController(true, withViewOptions: nil)
            for view in pdfView.subviews {
                view.backgroundColor = .clear
            }

        case .list:
            pdfView.displayDirection = .vertical
        }
    }

    private func showPageNumberView() {
        guard let document = pdfView.document, let currentPage = pdfView.currentPage else { return }
        let currentPageNumber = document.index(for: currentPage) + 1
        pageNumberView.setup(currentPageNumber: currentPageNumber, totalPageNumber: document.pageCount)
    }
    
    private func loadPDF() {
//        storage.loadDocument(fromPath: materialItem.digitalPrintPath,
//                             onProgress: { [weak self] (progress) in
//            self?.progressView.progress = progress
//        }) { [weak self] (path, success, error) in
//            guard let path = path, let document = PDFDocument(url: URL(fileURLWithPath: path)) else { return }
//
//            self?.pdfView.document = document
//            self?.progressView.isHidden = true
//            self?.showPageNumberView()
//            self?.configurePDFView()
//        }
        
        guard let path = materialItem.path, let document = PDFDocument(url: URL(fileURLWithPath: path)) else { return }
        pdfView.document = document
    }
    
//    private func logPDFProgress() {
//        guard let document = pdfView.document, let currentPage = pdfView.currentPage else { return }
//        let currentPageNumber = document.index(for: currentPage) + 1
//        let progress = CGFloat(currentPageNumber) / CGFloat(document.pageCount)
//        OBIService.shared()?.saveUserActionLog(forPDF: materialItem.digitalPrintID,
//                                               progress: CGFloat(progress),
//                                               withHandler: { (success, object, responseData, error, finalNetworkData) in
//
//        })
//    }
    
    //MARK: - Actions
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        isNavigationHidden = !isNavigationHidden
         
        if isNavigationHidden {
            pageNumberView.hide()
        } else {
            pageNumberView.show()
        }
        
        thumbnailView.isHidden = isNavigationHidden
        headerView.isHidden = isNavigationHidden
        noteView.textView.resignFirstResponder()
        delegate?.didTapGesture(tapGestureRecognizer)
    }

    @objc func pdfViewPageChanged() {
        showPageNumberView()
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
    }
        
    @objc func didEnterBackground(_ notification: Notification) {
//        logPDFProgress()
    }
    
    @objc private func onOrientationChange(_ notification: Notification) {
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.autoScales = true
        setNeedsStatusBarAppearanceUpdate()
    }
}

//MARK: - UIGestureRecognizerDelegate
extension CPDFReaderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - CPDFViewHeaderViewDelegate
@available(iOS 11.0, *)
extension CPDFReaderViewController: CPDFViewHeaderViewDelegate {
    func dissmissAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func writeNoteAction(_ sender: UIButton) {
        noteView.textView.becomeFirstResponder()
    }
    
    func saveAction(_ sender: UIButton) {
        
    }
    
    func moreAction(_ sender: UIButton) {
        
    }
    
    func dissmissAction() {
//        logPDFProgress()
        noteView.textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func searchAction() {
//        self.present(searchViewController, animated: true, completion:nil)
    }
    
    func shareAction(_ sender: UIButton) {
//        storage.loadDocument(fromPath: materialItem.digitalPrintPath,
//                             onProgress: { (progress) in
//        }) { [weak self] (path, success, error) in
//            if let self = `self` {
//                guard let path = path, let pdfData = NSData(contentsOfFile: path) else {
//                    self.showSomethingWentWrongAlert()
//                    return
//                }
//
//                let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
//                activityViewController.popoverPresentationController?.sourceView = sender
//                self.present(activityViewController, animated: true, completion: nil)
//            }
//        }+
    }
}

////MARK: - SearchTableViewControllerDelegate
//@available(iOS 11.0, *)
//extension CPDFReaderViewController: CPDFReaderSearchControllerDelegate {
//    func searchTableViewController(didSelectSerchResult selection: PDFSelection) {
//        pdfView.currentSelection = selection
//        
//        guard let selections = pdfView.currentSelection?.selectionsByLine() else { return }
//        guard let page = selections.first?.pages.first else { return }
//        self.page = page
//        
//        let highlight = PDFAnnotation(bounds: selection.bounds(for: page), forType: .highlight, withProperties: nil)
//        highlight.color = .yellow
//        page.addAnnotation(highlight)
//        pdfView.go(to: page)
//        pdfView.currentSelection = nil
//    }
//}


//MARK: - CPDFViewHeaderViewDelegate
@available(iOS 11.0, *)
extension CPDFReaderViewController: PDFViewDelegate {
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        UIApplication.shared.open(url)
    }
}

//MARK: - CPDFNoteViewDelegate
@available(iOS 11.0, *)
extension CPDFReaderViewController: CPDFNoteViewDelegate {
    func sendAction(_ sender: UIButton) {
        tapGestureRecognizer.isEnabled = true

    }
}





