//
//  NewMessageController.swift
//  randevoo
//
//  Created by Xell on 24/12/2563 BE.
//  Copyright © 2563 BE Lex. All rights reserved.
//

import UIKit
import FirebaseFirestore
import ObjectMapper

class NewMessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainTabBar: UITabBar!
    var personalAccID = ""
    var personalAccName = ""
    let userCell = "ComposeUserCell"
    var users : [ChatUser] = []
    var result : [ChatUser] = []
    var isSearching = false
    let db = Firestore.firestore()
    var rootVC : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        searchBar.delegate = self
        initialTopNav()
        setupUI()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveAllUser()
        searchBar.becomeFirstResponder()
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Store ..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.randevoo.mainLight
        table.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        table.allowsSelection = true
        //        table.isHidden = true
        return table
    }()
    
    private let noResultLabel : UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textAlignment = .center
        label.text = "No Result"
        label.font = UIFont(name: "Quicksand-Regular", size: 20)
        return label
    }()
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ComposeUserCell.self, forCellReuseIdentifier: userCell)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    private func setupUI(){
        view.addSubview(noResultLabel)
        noResultLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    }
    
    private func initialTopNav(){
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissView))
    }
    
    func retrieveAllUser() {
        users.removeAll()
        db.collection("users").getDocuments() {
            (querySnapShot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapShot!.documents {
                    let currentData = Mapper<PersonalAccount>().map(JSONObject: document.data())
                    if !self.users.contains(where: {user in user.id == currentData?.id}){
                        if String(currentData!.id) != self.personalAccID {
                            self.users.append(ChatUser(imageUrl: String((currentData?.profileUrl)!), id: String((currentData?.id)!), name: String((currentData?.name)!), lastChat: String((currentData?.username)!), createdAt: Date(), isRead: false))
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction private func dismissView(){
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension NewMessageController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        result.removeAll()
        self.searchUser(name: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        result = users.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        updateUI()
        tableView.reloadData()
    }
    
    func searchUser (name : String) {
        let capitalName = name.uppercased()
        db.collection("users").whereField("fullName", isGreaterThanOrEqualTo: capitalName).whereField("fullName", isLessThanOrEqualTo: name).getDocuments() {
            (querySnapShot, err) in
            if let err = err {
                print("Error: \(err)")
            }else{
                for document in querySnapShot!.documents {
                    let currentData = Mapper<PersonalAccount>().map(JSONObject: document.data())
                    self.result.append(ChatUser(imageUrl: String((currentData?.profileUrl)!), id: String((currentData?.id)!), name: String((currentData?.name)!), lastChat: String((currentData?.username)!), createdAt: Date(), isRead: false))
                    print(currentData!.name as Any)
                }
                self.updateUI()
                self.tableView.reloadData()
            }
        }
    }
    
    func updateUI() {
        if result.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

extension NewMessageController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return result.count
        }else{
            return users.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! ComposeUserCell
        if isSearching {
            if users[indexPath.item].imageUrl != "" {
                cell.userImg.af.setImage(withURL: URL(string: result[indexPath.item].imageUrl)!)
            }
            cell.userName.text = result[indexPath.item].name
        } else {
            if users[indexPath.item].imageUrl != "" {
                cell.userImg.af.setImage(withURL: URL(string: users[indexPath.item].imageUrl)!)
            }
            cell.userName.text = users[indexPath.item].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let directChat = ChatController()
        if isSearching {
            directChat.destinationUserID = result[indexPath.item].id
            directChat.destinationUserName = result[indexPath.item].name
            directChat.destinationProfileUrl = result[indexPath.item].imageUrl
        } else{
            directChat.destinationUserID = users[indexPath.item].id
            directChat.destinationUserName = users[indexPath.item].name
            directChat.destinationProfileUrl = users[indexPath.item].imageUrl
        }
        directChat.sourceUserID = personalAccID
        directChat.sourceUserName = personalAccName
        dismiss(animated: true, completion: {
            self.rootVC.navigationController?.pushViewController(directChat, animated: true)
            
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

