//
//  ChatController.swift
//  randevoo
//
//  Created by Lex on 23/12/2020.
//  Copyright © 2020 Lex. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import ObjectMapper
import SwiftyJSON
import InputBarAccessoryView
import AlamofireImage
import YPImagePicker
import AVKit
import Hydra
import SnapKit
import IQKeyboardManagerSwift

class MessageController: MessagesViewController {

    var messenger: Messenger!
    
    private var alertHelper = AlertHelper()
    private let db = Firestore.firestore()
    private var businessRef: CollectionReference!
    private var userRef: CollectionReference!
    private var messengerRef: CollectionReference!
    private var messageRef: CollectionReference!
    private var notificationRef: CollectionReference!
    private let timestampHelper = TimestampHelper()
    private let messagesProvider = MessagesProvider()
    private var alertController: UIAlertController!
    private var config = YPImagePickerConfiguration()
    
    private var messages: [Message] = []
    private var messageIds: [String] = []
    
    private var currentMember = Sender(photoURL: "", senderId: "", displayName: "")
    private var currentUser = Sender(photoURL: "", senderId: "", displayName: "")
    
    private var user: User!
    private var member: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavItems()
        hideSideLayout()
        setupAddingPhoto()
        imagePickerConfig()
        initiateAccount()
        initiateFirestore()
        initialCollectionView()
        verifyMember()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.isOpaque = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func hideSideLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
    }
    
    private func initiateAccount() {
        if isPersonalAccount {
            guard let personal = personalAccount else { return }
            user = personal.getUser()
            currentUser = Sender(photoURL: personal.profileUrl, senderId: personal.id, displayName: personal.username)
        } else {
            guard let business = businessAccount else { return }
            user = business.getUser()
            currentUser = Sender(photoURL: business.profileUrl, senderId: business.id, displayName: business.username)
        }
    }
    
    private func initiateMember() {
        guard let messenger = messenger else { return }
        member = messenger.user
        currentMemberId = member.id
        setupNavProfile()
    }
    
    private func initiateFirestore() {
        businessRef = db.collection("businesses")
        userRef = db.collection("users")
        messengerRef = db.collection("messengers")
        messageRef = db.collection("messages")
    }
    
    private func initialCollectionView() {
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        messagesCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        showMessageTimestampOnSwipeLeft = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
    }
    
    private func verifyMember() {
        guard let messenger = messenger else { return }
        if messenger.user.id != "" {
            print("Initiate Member is not empty")
            initiateMember()
            fetchRealtimeMessages()
        } else {
            print("Initiate Member is empty")
            manipulateMember(accountId: user.id).then { (check) in
                if check {
                    self.messenger.user = self.member
                    self.initiateMember()
                    self.fetchRealtimeMessages()
                }
            }
        }
    }
    
    private func manipulateMember(accountId: String)  -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            guard let messenger = self.messenger else {
                resolve(false)
                return
            }
            if let memberId = messenger.members.first(where: {$0 != accountId}) {
                if isPersonalAccount {
                    self.fetchStore(memberId: memberId).then { (result) in
                        resolve(result)
                    }
                } else {
                    self.fetchUser(memberId: memberId).then { (result) in
                        resolve(result)
                    }
                }
            }
        }
    }
    
    private func fetchStore(memberId: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.businessRef.document(memberId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.member = Mapper<User>().map(JSONObject: document.data())!
                    resolve(true)
                } else {
                    print("Document does not exist")
                    resolve(false)
                }
            }
        }
    }

    private func fetchUser(memberId: String) -> Promise<Bool> {
        return Promise<Bool>(in: .background) { (resolve, reject, _) in
            self.userRef.document(memberId).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.member = Mapper<User>().map(JSONObject: document.data())!
                    resolve(true)
                } else {
                    print("Document does not exist")
                    resolve(false)
                }
            }
        }
    }
    
    private func cleanMessage() {
        messages.removeAll()
        guard let messageListener = messageListener else { return }
        messageListener.remove()
    }
    
    private func getMessageKind(message: iMessage) -> MessageKind {
        if message.type == "photo"{
            var kind: MessageKind
            let imageUrl = URL(string: (message.content)!)
            let placeHolder = UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal)
            let width = self.view.frame.width * 3 / 4
            let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: width, height: width))
            kind = .photo(media)
            return kind
        } else {
            var attributes: NSAttributedString!
            if message.senderId == user.id {
                attributes = NSAttributedString(
                    string: message.content,
                    attributes: [
                        .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                        .foregroundColor: UIColor.white,
                    ]
                )
            } else {
                attributes = NSAttributedString(
                    string: message.content,
                    attributes: [
                        .font: UIFont(name: "Quicksand-Regular", size: 18)!,
                        .foregroundColor: UIColor.black,
                    ]
                )
            }
            return .attributedText(attributes)
        }
    }
    
    private func fetchRealtimeMessages() {
        cleanMessage()
        messageListener = self.messageRef
            .document(self.messenger.id)
            .collection("contents")
            .order(by: "createdAt", descending: false)
            .limit(to: 300)
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching business document: \(error!)")
                    return
                }
                document.documentChanges.forEach { diff in
                    if (diff.type == .added) {
//                        let record = diff.document.data()
//                        print("New message: \(record)")
                        let iMessage = Mapper<iMessage>().map(JSONObject: diff.document.data())!
                        var message: Message!
                        let kind = self.getMessageKind(message: iMessage)
                        if iMessage.senderId == self.user.id {
                            message = Message(sender: self.currentUser, messageId: iMessage.id, sentDate: iMessage.createdAt.iso8601withFractionalSeconds!, kind: kind)
                        } else {
                            message = Message(sender: self.currentMember, messageId: iMessage.id, sentDate: iMessage.createdAt.iso8601withFractionalSeconds!, kind: kind)
                            if iMessage.isRead == false {
                                self.messagesProvider.updateMessageState(messengerId: self.messenger.id, messageId: iMessage.id)
                            }
                        }
                        self.messages = self.messages.filter { $0.messageId != message.messageId }
                        self.messageIds = self.messageIds.filter { $0 != message.messageId }
                        self.messages.append(message)
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem()
                    }
                    if (diff.type == .modified) {
//                        print("Modified message: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
//                        print("Removed message: \(diff.document.data())")
                    }
                }
                self.messages = self.messages.sorted(by: { $0.sentDate.compare($1.sentDate) == .orderedAscending})
                self.messagesCollectionView.reloadData()
            }
    }
    
    private func setupNavProfile() {
        let titleLabel = UILabel()
        titleLabel.text = member.username
        titleLabel.textColor = UIColor.randevoo.mainBlack
        titleLabel.font = UIFont(name: "Quicksand-Bold", size: 17)
        navigationItem.titleView = titleLabel
        
        let memberImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
            imageView.layer.cornerRadius = 40/2
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.randevoo.mainWhiteGray.cgColor
            imageView.backgroundColor = UIColor.randevoo.mainWhiteGray
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        if member.profileUrl != "" {
            memberImageView.loadCacheImage(urlString: (member.profileUrl)!)
        } else {
            memberImageView.image = UIImage(named: "ProfileIcon")!.withRenderingMode(.alwaysOriginal)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: memberImageView)
        memberImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
        }
    }
    
    @IBAction func handleBack(_ sender: Any?) {
        currentMemberId = ""
        cleanMessage()
        print("Cleaned Message Listener")
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setupNavItems() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "ArrowLeft")!.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        backButton.contentHorizontalAlignment = .center
        backButton.contentVerticalAlignment = .center
        backButton.contentMode = .scaleAspectFit
        backButton.backgroundColor = UIColor.clear
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(handleBack(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        backButton.snp.makeConstraints{ (make) in
            make.height.width.equalTo(40)
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.navigationBar.barTintColor = UIColor.randevoo.mainLight
        navigationController?.view.backgroundColor = UIColor.randevoo.mainLight
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}


extension MessageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupAddingPhoto() {
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
    
    func presentInputActionSheet() {
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
                        let messageId = messageRef.document().documentID
                        let message = Message(sender: currentUser, messageId: messageId, sentDate: Date(), kind: .text("Processing..."))
                        self.messageIds.append(messageId)
                        self.messages.append(message)
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem()
                        
                        self.messagesProvider.savePhoto(with: imageData!).then { (result) in
                            if result != "" {
                                let url = URL(string: result)
                                let media = Media(url: url, image: nil, placeholderImage: UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal), size: .zero)
                                let message = Message(sender: self.currentUser, messageId: messageId, sentDate: Date(), kind: .photo(media))
                                self.messages = self.messages.filter { $0.messageId != message.messageId }
                                self.messages.append(message)
                                
                                self.messagesProvider.saveMessage(messengerId: self.messenger.id, senderId: self.user.id, receiverId: self.member.id, message: message).then { (check) in
                                    if check {
//                                        print("Message is sent")
                                    }
                                }
                                
                            } else {
                                print("Send photo failed")
                            }
                        }
                        
                    case .video(let video):
                        print(video)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData() else {
            return
        }
        
        let messageId = messageRef.document().documentID
        let message = Message(sender: currentUser, messageId: messageId, sentDate: Date(), kind: .text("Processing.."))
        self.messageIds.append(messageId)
        self.messages.append(message)
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
        
        self.messagesProvider.savePhoto(with: imageData).then { (result) in
            if result != "" {
                let url = URL(string: result)
                let media = Media(url: url, image: nil, placeholderImage: UIImage(named: "DefaultPhoto")!.withRenderingMode(.alwaysOriginal), size: .zero)
                let message = Message(sender: self.currentUser, messageId: messageId, sentDate: Date(), kind: .photo(media))
                self.messages = self.messages.filter { $0.messageId != message.messageId}
                self.messages.append(message)
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
                
                self.messagesProvider.saveMessage(messengerId: self.messenger.id, senderId: self.user.id, receiverId: self.member.id, message: message).then { (check) in
                    if check {
                        print("Message is sent")
                    }
                }
                
            } else {
                print("Send photo failed")
            }
        }
    }
}

extension MessageController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty || content == "" {
            print("It's empty, type")
            return
        }
        
        let messageId = messageRef.document().documentID
        let message = Message(sender: currentUser, messageId: messageId, sentDate: Date(), kind: .text(content))
        messageIds.append(messageId)
        messages.append(message)
        
        inputBar.inputTextView.text = ""
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
        
        self.messagesProvider.saveMessage(messengerId: messenger.id, senderId: user.id, receiverId: member.id, message: message).then { (check) in
            if check {
                print("Message is sent")
            } else {
                print("Message is failed")
            }
        }
    }
}



extension MessageController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func currentSender() -> SenderType {
        return currentUser
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
                .font: UIFont(name: "Quicksand-Medium", size: 15)!,
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
            ]
        )
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        for id in messageIds {
            if message.messageId == id {
                return UIColor.randevoo.mainLightBlue
            }
        }
        return isFromCurrentSender(message: message) ? UIColor.randevoo.mainColor : UIColor.randevoo.mainGreyLight
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
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
        } else {
            previousDate = messages[indexPath[0] - 1 ].sentDate.millisecondsSince1970
        }
        let message = messageForItem(at: indexPath, in: messagesCollectionView)
        if message.sentDate.millisecondsSince1970 - previousDate >= 3600000 {
            header.setup(with: timestampHelper.toDateMedium(date: message.sentDate))
        } else if indexPath[0] == 0 {
            header.setup(with: timestampHelper.toDateMedium(date: message.sentDate))
        }
        return header
    }
}

extension MessageController: MessageCellDelegate {
    
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
                let controller = ImageViewerController(with: imageUrl)
                controller.modalPresentationStyle = .overCurrentContext
                let navController = UINavigationController(rootViewController: controller)
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
        config.startOnScreen = YPPickerScreen.library
//        config.screens = [.library, .photo]
        config.screens = [.library]
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
        config.library.defaultMultipleSelection = false
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


class HeaderReusableView: MessageReusableView {
    static private let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "Quicksand-Regular", size: 15)!,
        .foregroundColor: UIColor.black
    ]
    static private let insets = UIEdgeInsets(top: 12, left: 80, bottom: 12, right: 80)

    private var label: UILabel!

    static var height: CGFloat {
        return insets.top + insets.bottom + 27
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
    }

    func setup(with text: String) {
        label.attributedText = NSAttributedString(string: text, attributes: HeaderReusableView.attributes)
    }

    override func prepareForReuse() {
        label.attributedText = nil
    }

    private func createUI() {
        let insets = HeaderReusableView.insets
        let frame = bounds.inset(by: insets)
        label = UILabel(frame: frame)
        label.preferredMaxLayoutWidth = frame.width
        label.numberOfLines = 1
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.black
        label.clipsToBounds = true
        addSubview(label)
    }
}
