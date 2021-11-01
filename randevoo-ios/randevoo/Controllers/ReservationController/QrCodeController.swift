//
//  QrCodeController.swift
//  randevoo
//
//  Created by Xell on 25/2/2564 BE.
//  Copyright © 2564 BE Lex. All rights reserved.
//

import UIKit

class QrCodeController: UIViewController {
    
    var reservationCode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setupUI()
        generateQrCode()
    }
    
    private func setupUI(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(qrImageView)
        let qrWidth = view.frame.width / 2
        qrImageView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.height.equalTo(qrWidth)
        }
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.top.equalTo(view).inset(10)
            make.centerX.equalTo(view)
            make.height.equalTo(4)
            make.width.equalTo(40)
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    private func generateQrCode() {
        let data = reservationCode.data(using: String.Encoding.ascii)
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        qrImageView.image = UIImage(ciImage: scaledQrImage)
    }
    
    var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.randevoo.mainBlueGrey.withAlphaComponent(0.5)
        view.layer.cornerRadius = 2
        return view
    }()
}
