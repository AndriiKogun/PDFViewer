//
//  ViewController.swift
//  PDFViewer
//
//  Created by Andrii on 12/23/19.
//  Copyright © 2019 Andrii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func action(_ sender: Any) {
        let vc = CPDFViewerController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}

