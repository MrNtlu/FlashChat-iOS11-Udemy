//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    var messageArray:[Message] = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.delegate=self
        messageTableView.dataSource=self
        messageTextfield.delegate=self
        messageTableView.separatorStyle = .none
        
        let tapGesture=UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        
        retrieveMessages()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text=messageArray[indexPath.row].messageBody
        cell.senderUsername.text=messageArray[indexPath.row].sender
        if cell.senderUsername.text! == Auth.auth().currentUser?.email {
            cell.messageBackground.backgroundColor=UIColor.blue
        }
        cell.avatarImageView.image=UIImage(named: "egg")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    func configureTableView(){
        messageTableView.rowHeight=UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight=120.0
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight=keyboardSize.height
            UIView.animate(withDuration: 0.5){
                self.heightConstraint.constant=50+keyboardHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=50
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true);
        messageTextfield.isEnabled=false;
        sendButton.isEnabled=false;
        
        let messagesDB=Database.database().reference().child("Messages");
        let messageDictionary = ["Sender":Auth.auth().currentUser?.email,"MessageBody":messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error,reference) in
            
            if error != nil{
                print(error!)
            }else{
                print("Message saved successfully.")
                
                self.messageTextfield.isEnabled=true;
                self.sendButton.isEnabled=true;
                self.messageTextfield.text="";
            }
        };
    }
    
    func retrieveMessages(){
        let messageDB=Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) {
            (snapshot) in
            
            let snapshatValue=snapshot.value as! Dictionary<String,String>
            
            let text=snapshatValue["MessageBody"]!
            let sender=snapshatValue["Sender"]!
            
            let message=Message()
            message.messageBody=text
            message.sender=sender
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("error, there was a problem.")
        }
    }
    


}
