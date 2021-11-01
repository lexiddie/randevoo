//
//  UIViewController.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import SnapKit

extension UIViewController {
    
     override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
     }
    
    @objc
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func displaySpinner(title: String = "Creating...") -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        alert.view.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.centerY.equalTo(alert.view)
            make.width.height.equalTo(50)
        }
        self.present(alert, animated: true, completion: nil)
        return alert
    }
    
    func displayFullSpinner() -> UIAlertController {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        alert.setBackgroundColor(color: UIColor.clear.withAlphaComponent(0))
        alert.setTint(color: UIColor.clear.withAlphaComponent(0))
        alert.setTitle(font: .systemFont(ofSize: 17), color: UIColor.clear.withAlphaComponent(0))
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        alert.view.addSubview(spinner)
        spinner.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(alert.view)
            make.width.height.equalTo(50)
        }
        self.present(alert, animated: true, completion: nil)
        return alert
    }
    
//    public func dch_checkDeallocation(afterDelay delay: TimeInterval = 2.0) {
//        let rootParentViewController = dch_rootParentViewController
//
//        // We don’t check `isBeingDismissed` simply on this view controller because it’s common
//        // to wrap a view controller in another view controller (e.g. in UINavigationController)
//        // and present the wrapping view controller instead.
//        if isMovingFromParent || rootParentViewController.isBeingDismissed {
//            let type = self
//            let disappearanceSource: String = isMovingFromParent ? "removed from its parent" : "dismissed"
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
//                assert(self == nil, "\(type) not deallocated after being \(disappearanceSource)")
//            })
//        }
//    }
//
//    private var dch_rootParentViewController: UIViewController {
//        var root = self
//
//        while let parent = root.parent {
//            root = parent
//        }
//
//        return root
//    }

}


