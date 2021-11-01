//
//  ScannerController.swift
//  randevoo
//
//  Created by Lex on 25/2/21.
//  Copyright © 2021 Lex. All rights reserved.
//

import UIKit
import AVKit

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var businessController: UIViewController!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        setupCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    private func setupCapture() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.addSubview(scannerImageView)
        scannerImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.height.width.equalTo(self.view.frame.width - 60)
        }
        self.view.backgroundColor = UIColor.randevoo.mainColor.withAlphaComponent(0.5)
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            let controller = businessController as! BusinessController
            controller.validateQrCode(qrCode: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print("Scanned Code", code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    let scannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "QrCodeScanner")!.withRenderingMode(.alwaysOriginal)
        imageView.layer.cornerRadius = 0
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    @IBAction func handleDismiss(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavItems() {
        let dismissBarButton = UIBarButtonItem(image: UIImage(named: "WhiteDismissIcon")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss(_:)))
        navigationItem.leftBarButtonItem = dismissBarButton
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
    }
}
