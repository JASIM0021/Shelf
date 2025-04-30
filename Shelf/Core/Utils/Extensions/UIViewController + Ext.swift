//
//  UIViewController + Ext.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 01/05/25.
//

import Foundation
import UIKit
extension UIViewController {
    private struct AssociatedKeys {
        static var activityIndicator = "activityIndicator"
      }
      private var activityIndicator: UIActivityIndicatorView {
        get {
          if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView {
            return indicator
          } else {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.color = .white
            view.addSubview(indicator)
            NSLayoutConstraint.activate([
              indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            indicator.hidesWhenStopped = true
            objc_setAssociatedObject(self, &AssociatedKeys.activityIndicator, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return indicator
          }
        }
      }
      func startActivityIndicator() {
          
          
          
        DispatchQueue.main.async {
          self.activityIndicator.startAnimating()
          self.view.isUserInteractionEnabled = false
        }
      }
      func stopActivityIndicator() {
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.view.isUserInteractionEnabled = true
        }
      }
}
