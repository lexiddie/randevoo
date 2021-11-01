//
//  ChatController.swift
//  randevoo
//
//  Created by Xell on 20/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import ObjectMapper
import InputBarAccessoryView
import AlamofireImage
import YPImagePicker
import AVKit
import Hydra

class ChatController: MessagesViewController {
    
    private let timestampHelper = TimestampHelper()
    
    var otherUser = Sender(photoURL: "abc", senderId: "other", displayName: "None")
    var selfSender = Sender(photoURL: "abc", senderId: "other", displayName: "None")
    var destinationUserID = ""
    var destinationUserName = ""
    var destinationProfileUrl = ""
    var sourceUserID = ""
    var sourceUserName = ""
    var messages = [MessageType]()
    var currentGenID:[String] = []
    let db = Firestore.firestore()
    private var config = YPImagePickerConfiguration()
    let databaseManager = DatabaseManager()
    let userHelper = UserHelper()
    let alertHelper = AlertHelper()
    var isLoadFromNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollsToLastItemOnKeyboardBeginsEditing = true
        print("self user \(sourceUserID)")
        print("destination user \(destinationUserID)")
//        navigationItem.title = destinationUserName
        otherUser = Sender(photoURL: "None", senderId: destinationUserID, displayName: destinationUserName)
        selfSender = Sender(photoURL: "None", senderId: sourceUserID, displayName: sourceUserName)
        retreiveChat()
        retrieveOtherSideChat()
        retrieveOtherSideLastChat()
        setupInputButton()
        loadFromNotification()
        hideAvatar()
        setupTopView()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        showMessageTimestampOnSwipeLeft = true
        imagePickerConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        self.messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func hideAvatar(){
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
    func loadFromNotification() {
        if isLoadFromNotification {
            let _ = async({_ -> PersonalAccount in
                let personal = try await(self.userHelper.retrievePersonalAcc(id: self.destinationUserID))
                return personal
            }).then({ [self] personal in
                if personal != nil {
                    destinationProfileUrl = personal.profileUrl
                    destinationUserName = personal.name
                    otherUser = Sender(photoURL: "None", senderId: destinationUserID, displayName: destinationUserName)
                    setupTopView()
                    self.messagesCollectionView.scrollToLastItem()
                } else {
                    let _ = async({_ -> BusinessAccount in
                        let biz = try await(self.userHelper.retrieveBusinessAcc(id: destinationUserID))
                        return biz
                    }).then({ [self] biz in
                        if biz != nil {
                            destinationProfileUrl = biz.profileUrl
                            destinationUserName = biz.name
                            otherUser = Sender(photoURL: "None", senderId: destinationUserID, displayName: destinationUserName)
                            setupTopView()
                            self.messagesCollectionView.scrollToLastItem()
                        }
                    })
                }
            })
        }

    }

    private func setupTopView(){
        print("this is top view \(destinationProfileUrl)")
        if self.navigationController == nil {
            return
        }
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.contentHorizontalAlignment = .center
        dismissButton.contentVerticalAlignment = .center
        dismissButton.contentMode = .scaleAspectFit
        dismissButton.backgroundColor = UIColor.clear
        dismissButton.layer.cornerRadius = 8
        dismissButton.addTarget(self, action: #selector(handleDismiss(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        dismissButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        let navView = UIView()
        navView.backgroundColor = UIColor.red
        let imgHeight = (navigationController?.navigationBar.bounds.height)! - 5
        let imageView : UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = imgHeight / 2
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.clipsToBounds = true
            if destinationProfileUrl != "" {
                imageView.af.setImage(withURL:  URL(string: destinationProfileUrl)!)
            } else {
                imageView.image = UIImage.init(named: "ProfileSelected")
            }
            return imageView
        }()
        let nameLabel : UILabel = {
            let label = UILabel()
            label.text = destinationUserName
            label.sizeToFit()
            label.textAlignment = .center
            label.font = UIFont(name: "Quicksand-Regular", size: 15)
            return label
        }()
        navView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.center.equalTo(navView)
        }
        let textWidth = nameLabel.intrinsicContentSize.width + 5
        navView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.right.equalTo(nameLabel.snp.right).inset(textWidth)
            make.centerY.equalTo(navView)
            make.width.height.equalTo(imgHeight)
        }
        self.navigationItem.titleView = navView
        navView.sizeToFit()
    }
    
    @IBAction func handleDismiss(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func retreiveLastChat(chatID: String){
        db.collection("chats").whereField("receiverId", isEqualTo: destinationUserID).whereField("senderId", isEqualTo: sourceUserID).whereField("id", isEqualTo: chatID).getDocuments(){
            (querySnapShot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Chat>().map(JSONObject: document.data())
                    let date = (currentData?.createdAt?.iso8601withFractionalSeconds)!
                    if currentData?.type == "text" {
                        let attributes = NSAttributedString(
                            string: (currentData?.content)!,
                            attributes: [
                                .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                                .foregroundColor: UIColor(white: 1, alpha: 1),
                            ]
                        )
                        self.messages.append(Message(sender: self.selfSender, messageId: (currentData?.id)!, sentDate: date, kind: .attributedText(attributes)))
                    } else if currentData?.type == "photo"{
                        var kind: MessageKind
                        let imageUrl = URL(string: (currentData?.content)!)
                        let placeHolder = UIImage(named: "Gallery")
                        let photoMessageWidth = self.view.frame.width * 3 / 4
                        let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder!, size: CGSize(width: photoMessageWidth, height: photoMessageWidth))
                        kind = .photo(media)
                        self.messages.append(Message(sender: self.selfSender, messageId: (currentData?.id)!, sentDate: date, kind: kind))
                    }
                    self.messages = self.messages.sorted(by: { $0.sentDate.compare($1.sentDate) == .orderedAscending})
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    func retreiveChat() {
        db.collection("chats").whereField("receiverId", isEqualTo:  destinationUserID).whereField("senderId", isEqualTo: sourceUserID).getDocuments(){
            (querySnapShot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapShot!.documents {
                    let currentData = Mapper<Chat>().map(JSONObject: document.data())
//                    let date = TimestampHelper().convertDate(timeMillis: (currentData?.createdAt)!)
                    let date = (currentData?.createdAt?.iso8601withFractionalSeconds)!
                    if currentData?.type == "text" {
                        let attributes = NSAttributedString(
                            string: (currentData?.content)!,
                            attributes: [
                                .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                                .foregroundColor: UIColor(white: 1, alpha: 1),
                            ]
                        )
                        self.messages.append(Message(sender: self.selfSender, messageId: (currentData?.id)!, sentDate: date, kind: .attributedText(attributes)))
                    } else if currentData?.type == "photo"{
                        var kind: MessageKind
                        let imageUrl = URL(string: (currentData?.content)!)
                        let placeHolder = UIImage(named: "Gallery")
                        let photoMessageWidth = self.view.frame.width * 3 / 4
                        let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder!, size: CGSize(width: photoMessageWidth, height: photoMessageWidth))
                        kind = .photo(media)
                        self.messages.append(Message(sender: self.selfSender, messageId: (currentData?.id)!, sentDate: date, kind: kind))
                    }
                }
                self.messages = self.messages.sorted(by: { $0.sentDate.compare($1.sentDate) == .orderedAscending})
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    func retrieveOtherSideChat(){
        db.collection("chats").whereField("receiverId", isEqualTo:  sourceUserID).whereField("senderId", isEqualTo: destinationUserID).whereField("isRead", isEqualTo: true).getDocuments(){
            (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapshot!.documents {
                    let currentData = Mapper<Chat>().map(JSONObject: document.data())
                    let date = (currentData?.createdAt?.iso8601withFractionalSeconds)!
                    if !(currentData?.isRead)! {
                        self.databaseManager.updateIsRead(id: (currentData?.id)!)
                    }
                    if currentData?.type == "text" {
                        if !self.messages.contains(where: { message in message.messageId == currentData?.id }) {
                            let attributes = NSAttributedString(
                                string: (currentData?.content)!,
                                attributes: [
                                    .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                                    .foregroundColor: UIColor(white: 0, alpha: 1),
                                ]
                            )
                            self.messages.append(Message(sender: self.otherUser, messageId: (currentData?.id)!, sentDate: date, kind: .attributedText(attributes)))
                        }
                    } else if currentData?.type == "photo"{
                        var kind: MessageKind
                        let imageUrl = URL(string: (currentData?.content)!)
                        let placeHolder = UIImage(named: "Gallery")
                        let photoMessageWidth = self.view.frame.width * 3 / 4
                        let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder!, size: CGSize(width: photoMessageWidth, height: photoMessageWidth))
                        kind = .photo(media)
                        if !self.messages.contains(where: { message in message.messageId == currentData?.id }) {
                            self.messages.append(Message(sender: self.otherUser, messageId: (currentData?.id)!, sentDate: date, kind: kind))
                        }
                    }
                }
                self.messages = self.messages.sorted(by: { $0.sentDate.compare($1.sentDate) == .orderedAscending})
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    func retrieveOtherSideLastChat(){
        db.collection("chats").whereField("receiverId", isEqualTo:  sourceUserID).whereField("senderId", isEqualTo: destinationUserID).whereField("isNotify", isEqualTo: false)
            .addSnapshotListener { querySnapshot, err in
                if let err = err {
                    print("Error: \(err)")
                }else{
                    for document in querySnapshot!.documents {
                        let currentData = Mapper<Chat>().map(JSONObject: document.data())
                        let date = currentData!.createdAt!.iso8601withFractionalSeconds!
                        self.databaseManager.updateIsNotify(id: (currentData?.id)!)
                        if currentData?.type == "text" {
                            DatabaseManager().updateIsRead(id: (currentData?.id)!)
                            if !self.messages.contains(where: { message in message.messageId == currentData?.id }) {
                                let attributes = NSAttributedString(
                                    string: (currentData?.content)!,
                                    attributes: [
                                        .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                                        .foregroundColor: UIColor(white: 0, alpha: 1),
                                    ]
                                )
                                self.messages.append(Message(sender: self.otherUser, messageId: (currentData?.id)!, sentDate: date, kind: .attributedText(attributes)))
                            }
                        } else if currentData?.type == "photo"{
                            var kind: MessageKind
                            let imageUrl = URL(string: (currentData?.content)!)
                            let placeHolder = UIImage(named: "Gallery")
                            let photoMessageWidth = self.view.frame.width * 3 / 4
                            let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder!, size: CGSize(width: photoMessageWidth, height: photoMessageWidth))
                            kind = .photo(media)
                            DatabaseManager().updateIsRead(id: (currentData?.id)!)
                            if !self.messages.contains(where: { message in message.messageId == currentData?.id }) {
                                self.messages.append(Message(sender: self.otherUser, messageId: (currentData?.id)!, sentDate: date, kind: kind))
                            }
                        }
                        self.messages = self.messages.sorted(by: { $0.sentDate.compare($1.sentDate) == .orderedAscending})
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem()
                    }
                    
                }
            }
    }
    
    func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 20, height: 20), animated: false)
        button.setImage(UIImage(named: "AddingIcon"), for: .normal)
        button.onTouchUpInside {[weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.setLeftStackViewWidthConstant(to: 20, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    func presentInputActionSheet(){
        let picker = YPImagePicker(configuration: self.config)
        picker.didFinishPicking { [self, unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
            }
            for item in items {
                switch item {
                case .photo(let image):
                    let compressData = image.image.jpegData(compressionQuality: 0.3)
                    let imageData = compressData
                    let users = db.collection("chats")
                    let genID = users.document().documentID
                    let thisDate = Date()
                    var mmessage = Message(sender: self.selfSender,  messageId: genID , sentDate: thisDate, kind: .text("Photo ."))
                    self.currentGenID.append(genID)
                    messages.append(mmessage)
                    self.messagesCollectionView.reloadData()
                    DatabaseManager().uploadPhotoToStorage(with: imageData!,fileName: genID, completion: { [self] result in
                        switch result {
                        case .success(let urlString):
                            print("upload complete: \(urlString)")
                            guard let url = URL(string: urlString), let placeholder = UIImage(named: "Gallery") else {
                                return
                            }
                            let thisDate = Date()
                            let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                            mmessage = Message(sender: self.selfSender, messageId: genID , sentDate: thisDate, kind: .photo(media))
                            self.messagesCollectionView.reloadData()
                            DatabaseManager().createNewMessage(with: self.destinationUserID, message: mmessage, completion: { success in
                                if success {
                                    print("Chat Sucess")
                                    messages = messages.filter { $0.messageId != mmessage.messageId}
                                    self.currentGenID = self.currentGenID.filter { $0 != mmessage.messageId }
                                    self.messagesCollectionView.reloadData()
            //                        messages.append(mmessage)
                                    retreiveLastChat(chatID: mmessage.messageId)
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToBottom()
                                }else{
                                    print("Faild")
                                }
                            })
                        case .failure(let error):
                            print("message photo upload faild: \(error)")
                        }
                    })
                   
                case .video(let video):
                    print(video)
                }
            }
            //                self.handleDisplaySlideShow(isUpdated: !cancelled)
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
}

extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData() else {
            return
        }
        let users = db.collection("chats")
        let genID = users.document().documentID
        let thisDate = Date()
        var mmessage = Message(sender: self.selfSender, messageId: genID , sentDate: thisDate, kind: .text("Photo ."))
        self.currentGenID.append(genID)
        messages.append(mmessage)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
        DatabaseManager().uploadPhotoToStorage(with: imageData,fileName: genID, completion: { [self] result in
            switch result {
            case .success(let urlString):
                print("run this func")
//                print("upload complete: \(urlString)")
//                guard let url = URL(string: urlString), let placeholder = UIImage(named: "Gallery") else {
//                    return
//                }
                let url = URL(string: urlString)
                let placeholder = UIImage(named: "")
                let thisDate = Date()
                let media = Media(url: url, image: nil, placeholderImage: placeholder!, size: .zero)
                mmessage = Message(sender: self.selfSender, messageId: genID , sentDate: thisDate, kind: .photo(media))
                self.messagesCollectionView.reloadData()
                print("this is media")
//                print(media.url)
                DatabaseManager().createNewMessage(with: self.destinationUserID, message: mmessage, completion: { success in
                    if success {
                        print("Chat Sucess")
                        messages = messages.filter { $0.messageId != mmessage.messageId}
                        self.currentGenID = self.currentGenID.filter { $0 != mmessage.messageId }
                        self.messagesCollectionView.reloadData()
//                        messages.append(mmessage)
                        retreiveLastChat(chatID: mmessage.messageId)
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    } else {
                        print("Faild")
                    }
                })
            case .failure(let error):
                print("message photo upload faild: \(error)")
            }
        })
    }
}

extension ChatController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        let users = db.collection("chats")
        let genID = users.document().documentID
        let thisDate = Date()
        let mmessage = Message(sender: selfSender, messageId: genID, sentDate: thisDate, kind: .text(text))
        currentGenID.append(genID)
        messages.append(mmessage)
        inputBar.inputTextView.text = ""
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
        DatabaseManager().createNewMessage(with: destinationUserID, message: mmessage, completion: { success in
            if success {
                print("Chat Sucess")
                self.currentGenID = self.currentGenID.filter { $0 != mmessage.messageId }
                self.messagesCollectionView.reloadData()
            }else{
                print("Faild")
            }
        })
    }
}

extension ChatController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = messages[indexPath.section].sentDate
        let dateString = timestampHelper.toTimeShort(date: date)
        return NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont(name: "Quicksand-Regular", size: 14)!,
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
            ]
        )
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        for id in currentGenID {
            if message.messageId == id {
                return UIColor.randevoo.mainLightBlue
            }
        }
        return isFromCurrentSender(message: message) ? UIColor.randevoo.mainColor : UIColor.randevoo.mainLightGrey
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            // imageView.af.setImage(withURL: imageUrl)
            imageView.loadCacheImage(urlString: imageUrl.absoluteString)
        default:
            break
        }
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        var previousDate = messages[0].sentDate.millisecondsSince1970
        if section == 0 {
            previousDate = messages[section].sentDate.millisecondsSince1970
        }else{
            previousDate = messages[section - 1 ].sentDate.millisecondsSince1970
        }
        if messages[section].sentDate.millisecondsSince1970 - previousDate >= 3600000 {
            return CGSize(width: messagesCollectionView.bounds.width, height: HeaderReusableView.height)
        } else if section == 0 {
            return CGSize(width: messagesCollectionView.bounds.width, height: HeaderReusableView.height)
        } else {
            return .zero
        }
    }
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(HeaderReusableView.self, for: indexPath)
        var previousDate = messages[0].sentDate.millisecondsSince1970
        if indexPath[0] == 0 {
            previousDate = messages[indexPath[0]].sentDate.millisecondsSince1970
        }else{
            previousDate = messages[indexPath[0] - 1 ].sentDate.millisecondsSince1970
        }
        let message = messageForItem(at: indexPath, in: messagesCollectionView)
        if message.sentDate.millisecondsSince1970 - previousDate >= 3600000 {
            header.setup(with: timestampHelper.toDateTimeShort(date: message.sentDate))
        } else if indexPath[0] == 0 {
            header.setup(with: timestampHelper.toDateTimeShort(date: message.sentDate))
        }
        return header
    }
}



extension ChatController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let imageVC = ImageViewerController(with: imageUrl)
            imageVC.modalPresentationStyle = .overCurrentContext
            let navController = UINavigationController(rootViewController: imageVC)
            navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navController.navigationBar.shadowImage = UIImage()
            navController.navigationBar.isTranslucent = true
            navController.navigationBar.barTintColor = UIColor.clear
            present(navController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    private func imagePickerConfig() {
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "randevoo"
//        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.library
//        config.screens = [.library]
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.maxCameraZoomFactor = 1.0
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = .photo
        config.library.defaultMultipleSelection = true
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = true
        config.library.preselectedItems = nil
        
        config.video.compression = AVAssetExportPresetHighestQuality
        config.video.fileType = .mov
        config.video.recordingTimeLimit = 60.0
        config.video.libraryTimeLimit = 60.0
        config.video.minimumTimeLimit = 3.0
        config.video.trimmerMaxDuration = 60.0
        config.video.trimmerMinDuration = 3.0
    }
}


