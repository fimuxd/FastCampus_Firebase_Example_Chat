//
//  ChatViewController.swift
//  FirebaseExample
//
//  Created by Bo-Young PARK on 2020/02/09.
//  Copyright © 2020 Boyoung Park. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

struct MessageContent {
    let userID: String
    let message: String
    let order: Date
    
    init?(dictionary: [String: Any]) {
        guard let userID = dictionary["userID"] as? String,
            let message = dictionary["message"] as? String,
            let order = dictionary["order"] as? Timestamp else {
            return nil
        }
        self.userID = userID
        self.message = message
        self.order = order.dateValue()
    }
}

class ChatViewController: UIViewController {
    var db: Firestore!

    @IBOutlet weak var chatList: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    
    var messageContents: [MessageContent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Firebase Database 설정
        db = Firestore.firestore()
        updateWelcomeMessage()
        
        // (Optional) Keyboard 높이 설정
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        chatList.keyboardDismissMode = .onDrag
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        sendMessage()
    }
}

// MARK: read/write message from Firebase/Database
extension ChatViewController {
    private func updateWelcomeMessage() {
        db.collection("chats").whereField("userID", isEqualTo: "welcome").getDocuments { [weak self] docs, error in
            guard let docs = docs, !docs.isEmpty else {
                self?.addInitialDocument()
                return
            }
            self?.loadMessages()
        }
    }
    
    private func addInitialDocument() {
        db.collection("chats").addDocument(data: [
            "userID": "welcome",
            "message": "Firebase Chat App 캠퍼스톡에 오신 것을 환영합니다🎉",
            "order": FieldValue.serverTimestamp()
        ]) { [weak self] _ in
            self?.loadMessages()
        }
    }
    
    private func loadMessages() {
        db.collection("chats").addSnapshotListener { [weak self] snaps, _ in
            guard let snapshots = snaps else {
                return
            }
            
            self?.messageContents = []
            
            for snap in snapshots.documents {
                guard let message = MessageContent(dictionary: snap.data()) else {
                    return
                }
                self?.messageContents.append(message)
            }
            self?.messageContents.sort { $0.order < $1.order }
            self?.chatList.reloadData()
            self?.chatList.scrollToRow(at: (IndexPath(row: (self?.messageContents.count ?? 0) - 1, section: 0)), at: .bottom, animated: true)
        }
    }
    
    private func sendMessage() {
        let message: [String: Any] = [
            "userID": UIDevice.current.identifierForVendor!.uuidString,
            "message": messageTextField.text ?? "",
            "order": FieldValue.serverTimestamp()
        ]
        db.collection("chats").addDocument(data: message)
        messageTextField.text = ""
    }
}

// MARK: UITableView
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageContents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        let isMe = messageContents[indexPath.row].userID == UIDevice.current.identifierForVendor!.uuidString
        cell.setData(isMe: isMe, message: messageContents[indexPath.row].message)
        return cell
    }
}

// MARK: (Optional) Keyboard show/hide
extension ChatViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let window = UIApplication.shared.windows.first {
            let bottomPadding = window.safeAreaInsets.bottom
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (346 - bottomPadding)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
