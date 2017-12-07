//
//  ViewController.swift
//  TestRecognize
//
//  Created by Доловсков Владислав on 07.12.2017.
//  Copyright © 2017 Доловсков Владислав. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, RecognizerNameDelegade {
    
    var nameRecognizer: RecognizerName?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameRecognizer = RecognizerName(delegate: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameRecognizer?.startRecognize()
    }

    
    func showName(name: String) {
        if let helloDialog = HelloDialog.create(name: name, okAction: {self.nameRecognizer?.startRecognize()}) {
            self.present(helloDialog, animated: true, completion: nil)
        }
    }
    
 
}
