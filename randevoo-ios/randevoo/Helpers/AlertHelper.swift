//
//  AlertHelper.swift
//  randevoo
//
//  Created by Lex on 18/5/20.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit

class AlertHelper {
    
    func showAlert(title: String, alert: String, controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertDeleteVariation(title: String = "Are you sure to delete this variant?", controller: UIViewController, selection: Int) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let controller = controller as! BizProductController
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            controller.removeVariant(selection: selection)
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertUpdate(title: String = "Are you sure to update these products?", controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let controller = controller as! UpdateProductController
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            controller.dispatchUpdateProducts()
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertDeleteProduct(title: String = "Are you sure to delete this product?", controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let controller = controller as! BizProductController
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            controller.deletingProduct()
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertCancellation(title: String = "Are you sure you want to cancel this reservation?", controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let controller = controller as! ReservedProductController
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            controller.startCancellation()
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertBizProduct(title: String = "Would you like to make actions?", controller: UIViewController, product: Product) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! BizProductController
        let updateAlert = UIAlertAction(title: "Confirm Update", style: .default) { (_) in
            controller.updateProduct()
        }
        updateAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(updateAlert)
//        let updatePhotoAlert = UIAlertAction(title: "Update Photos", style: .default) { (_) in
//            controller.updatePhoto()
//        }
//        updatePhotoAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
//        alertController.addAction(updatePhotoAlert)
        if product.isAvailable {
            let disableAlert = UIAlertAction(title: "Disable Product", style: .default) { (_) in
                controller.disablingProduct()
            }
            disableAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
            alertController.addAction(disableAlert)
        } else {
            let enableAlert = UIAlertAction(title: "Enable Product", style: .default) { (_) in
                controller.enablingProduct()
            }
            enableAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
            alertController.addAction(enableAlert)
        }

        let deleteAlert = UIAlertAction(title: "Delete Product", style: .default) { (_) in
            controller.requestDeleteProduct()
        }
        deleteAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(deleteAlert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertBag(msg: String, controller: UIViewController) {
        let alert = UIAlertController(title: nil, message: "Succeed", preferredStyle: .alert)
        let imageView = UIImageView()
        imageView.loadGif(name: "bag")
        imageView.frame = CGRect(x: 10, y: -5, width: 60, height: 60)
        //        imageView.image = myImg
        alert.view.addSubview(imageView)
        alert.view.tintColor = UIColor.black
        controller.present(alert, animated: true, completion: nil)
        
        //Timer to dissmiss the animation just for demo
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            controller.dismiss(animated: true, completion: nil)
            let viewController = controller as! AddToListController
            viewController.dissmissView()
        }
    }
    
    func alertPending(title: String = "Would you like to make actions?", controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! ReservedProductController
        let approveAlert = UIAlertAction(title: "Approve", style: .default) { (_) in
            controller.startApproval()
        }
        approveAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(approveAlert)
        let declineAlert = UIAlertAction(title: "Decline", style: .default) { (_) in
            controller.startDecline()
        }
        declineAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(declineAlert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertApprove(title: String = "Would you like to make actions?", controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! ReservedProductController
        let completeAlert = UIAlertAction(title: "Complete", style: .default) { (_) in
            controller.startCompletion()
        }
        completeAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(completeAlert)
        let failAlert = UIAlertAction(title: "Fail", style: .default) { (_) in
            controller.startFailure()
        }
        failAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(failAlert)
        let cancelAlert = UIAlertAction(title: "Cancel Reservation", style: .default) { (_) in
            controller.requestCancellation()
        }
        cancelAlert.setValue(UIColor.randevoo.mainStatusRed, forKey: "titleTextColor")
        alertController.addAction(cancelAlert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertComplete(title: String = "Would you like to make actions?", controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! ReservedProductController
        let updateAlert = UIAlertAction(title: "Update Products", style: .default) { (_) in
            controller.dispatchUpdateProduct()
        }
        updateAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(updateAlert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertCancel(title: String = "Would you like to make actions?", controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! ReservedProductController
        let cancelAlert = UIAlertAction(title: "Approve Cancellation", style: .default) { (_) in
            
        }
        cancelAlert.setValue(UIColor.randevoo.mainColor, forKey: "titleTextColor")
        alertController.addAction(cancelAlert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func alertOther(title: String = "No actions needed to make!", controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentTitle = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.black])
        alertController.setValue(contentTitle, forKey: "attributedMessage")
        let controller = controller as! ReservedProductController
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertForAddToList(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: {
                let viewController = controller as! AddToListController
                viewController.dissmissView()
            })
        }
        alertController.addAction(alertAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithWarningForBizHour(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let controller = controller as! BusinessHoursController
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            controller.updateBizHour()
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.setBackgroundColor(color: UIColor.white)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWhenFailToConfirm(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: {
                let viewController = controller as! ConfirmReservationController
                viewController.dissmissView()
            })
        }
        alertController.addAction(alertAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertForUpdateList(title: String, alert: String, controller: UIViewController, previousController: UIViewController, personalAcc: String){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: {
                let viewController = controller as! EditListController
                let previous = previousController as! ListDetailsController
                viewController.dismiss(animated: true, completion: {
                    previous.lists.removeAll()
                    previous.disableSection.removeAll()
                    previous.retrieveProductFromList(personalId: personalAcc)
                })
            })
        }
        alertController.addAction(alertAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertForUpdateListForNoAction(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: {
                let viewController = controller as! EditListController
                viewController.dissmissView()
            })
        }
        alertController.addAction(alertAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showLocationAccess(title: String, alert: String, controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Not Now", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertController.addAction(alertAction)
        alertController.addAction(settingsAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDeleteProduct(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let viewController = controller as! CheckProductController
            viewController.deleteProduct()
            viewController.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertDeleteList(title: String, alert: String, controller: UIViewController, id: String){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let viewController = controller as! ListDetailsController
            alertController.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertSoldProduct(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let viewController = controller as! CheckProductController
            viewController.soldProduct()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertSaveProduct(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let viewController = controller as! CheckProductController
            viewController.saveProduct()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertUnsaveProduct(title: String, alert: String, controller: UIViewController){
        let alertController = UIAlertController(title: title, message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let viewController = controller as! CheckProductController
            viewController.unsavedProduct()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func displayCreateNewProductAlert(msg: String, controller: UIViewController) -> UIAlertController {
        let pending = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        pending.view.addSubview(loadingIndicator)
        controller.present(pending, animated: true)
        return pending
    }
    
    func displaySuccessAlert(msg: String, controller: UIViewController) -> UIAlertController {
        let imageView = UIImageView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        imageView.image = UIImage.init(named: "Ticks")
        let pending = UIAlertController(title: msg, message: nil, preferredStyle: .alert)
        pending.view.addSubview(imageView)
        controller.present(pending, animated: true)
        return pending
    }
    
}

