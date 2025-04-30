//
//  LaunchVC.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation
import UIKit
class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startActivityIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            
            self.stopActivityIndicator()
            guard let vc = BookListViewController.loadFromXIB() else {return}
            // Do any additional setup after loading the view.
            self.navigationController?.pushViewController(vc, animated: true)

        })
        
    }


}
