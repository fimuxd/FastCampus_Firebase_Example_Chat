//
//  ChatListCell.swift
//  FirebaseExample
//
//  Created by Bo-Young PARK on 2020/02/10.
//  Copyright © 2020 Boyoung Park. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    @IBOutlet weak var receiveMessageView: UIView!
    @IBOutlet weak var receiveMessageLabel: UILabel!
    
    @IBOutlet weak var myMessageView: UIView!
    @IBOutlet weak var myMessageLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        receiveMessageView.isHidden = true
        myMessageView.isHidden = true
    }
    
    func setData(isMe: Bool, message: String) {
        receiveMessageView.isHidden = isMe
        myMessageView.isHidden = !isMe
        
        receiveMessageView.layer.cornerRadius = 8
        myMessageView.layer.cornerRadius = 8
        
        receiveMessageLabel.text = message
        myMessageLabel.text = message
    }
}
