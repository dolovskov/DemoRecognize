//
//  HelloDialog.swift
//  TestRecognize
//
//  Created by Доловсков Владислав on 07.12.2017.
//  Copyright © 2017 Доловсков Владислав. All rights reserved.
//

import UIKit

class HelloDialog: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    private var name: String?
    private var okAction : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = name
    }
    
    static func create(name: String, okAction: @escaping (() -> Void)) -> UIViewController? {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helloDialog = storyboard.instantiateViewController(withIdentifier: "helloDialog") as? HelloDialog
        helloDialog?.modalTransitionStyle = .crossDissolve
        helloDialog?.modalPresentationStyle = .overFullScreen
        helloDialog?.name = name
        helloDialog?.okAction = okAction
        
        return helloDialog
    }
    
   
    @IBAction func okButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.okAction?()
    }
    
    
}
