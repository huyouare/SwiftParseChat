//
//  ChatViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/23/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Foundation

class ChatViewController: JSQMessagesViewController {
    
    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    
    var roomId: String = ""
    
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, UIImage>()
    
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var blankAvatarImage: JSQMessagesAvatarImage!
    
    var senderImageUrl: String!
    var batchMessages = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var user = PFUser.currentUser()
        self.senderId = user.objectId
        self.senderDisplayName = user[PF_USER_FULLNAME] as String
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "chat_blank"), diameter: 30)
        
        isLoading = false
        //self.loadMessages()
        // ClearMessageCounter(roomId);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // Mark: - Backend methods
    
    func loadMessages() {
        if isLoading == false {
            isLoading = true
            var lastMessage = messages.last
            
            var query = PFQuery(className: PF_CHAT_CLASS_NAME)
            query.whereKey(PF_CHAT_ROOMID, equalTo: roomId)
            if lastMessage != nil {
                query.whereKey(PF_CHAT_CREATEDAT, greaterThan: lastMessage?.date)
            }
            query.includeKey(PF_CHAT_USER)
            query.orderByDescending(PF_CHAT_CREATEDAT)
            query.limit = 50
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in objects as [PFObject]! {
                        self.addMessage(object)
                    }
                    if objects.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                } else {
                    ProgressHUD.showError("Network error")
                }
            })
        }
    }
    
    func addMessage(object: PFObject) {
        var message: JSQMessage
        
        var user = object[PF_CHAT_USER] as PFUser
        var name = user[PF_USER_FULLNAME] as String
        
        var videoFile = object[PF_CHAT_VIDEO] as? PFFile
        var pictureFile = object[PF_CHAT_PICTURE] as? PFFile
        
        if videoFile == nil && pictureFile == nil {
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String))
        }
        
        if videoFile != nil {
            var mediaItem = JSQVideoMediaItem(fileURL: NSURL(string: videoFile!.url), isReadyToPlay: true)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
        }
        
        if pictureFile != nil {
            var mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            
            pictureFile!.getDataInBackgroundWithBlock({ (imageData: NSData!, error: NSError!) -> Void in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData)
                    self.collectionView.reloadData()
                }
            })
        }
        
        users.append(user)
        messages.append(message)
    }
    
    func sendMessage(var text: String, video: NSURL?, picture: UIImage?) -> String {
        var videoFile: PFFile!
        var pictureFile: PFFile!
        
        if let video = video {
            text = "[Video message]"
            videoFile = PFFile(name: "video.move", data: NSFileManager.defaultManager().contentsAtPath(video.path!))
            
            videoFile.saveInBackgroundWithBlock({ (succeeed: Bool, error: NSError!) -> Void in
                if error != nil {
                    ProgressHUD.showError("Network error")
                }
            })
        }
        
        if let picture = picture {
            text = "[Picture message]"
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6))
            pictureFile.saveInBackgroundWithBlock({ (suceeded: Bool, error: NSError!) -> Void in
                if error != nil {
                    ProgressHUD.showError("Picture save error")
                }
            })
        }
        
        var object = PFObject(className: PF_CHAT_CLASS_NAME)
        object[PF_CHAT_USER] = PFUser.currentUser()
        object[PF_CHAT_ROOMID] = self.roomId
        object[PF_CHAT_TEXT] = text
        if let videoFile = videoFile {
            object[PF_CHAT_VIDEO] = videoFile
        }
        if let pictureFile = pictureFile {
            object[PF_CHAT_PICTURE] = pictureFile
        }
        object.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                
            }
        }
        
    }
    
    
//    func sendMessage(text: String!, sender: String!) {
//        // *** STEP 3: ADD A MESSAGE TO FIREBASE
//        messagesRef.childByAutoId().setValue([
//            "text":text,
//            "sender":sender,
//            "imageUrl":senderImageUrl
//            ])
//    }
//    
//    func tempSendMessage(text: String!, sender: String!) {
//        let message = Message(text: text, sender: sender, imageUrl: senderImageUrl)
//        messages.append(message)
//    }
//    
//    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
//        if imageUrl == nil ||  countElements(imageUrl!) == 0 {
//            setupAvatarColor(name, incoming: incoming)
//            return
//        }
//        
//        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
//        
//        let url = NSURL(string: imageUrl!)
//        let image = UIImage(data: NSData(contentsOfURL: url!)!)
//        let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
//        
//        avatars[name] = avatarImage
//    }
//    
//    func setupAvatarColor(name: String, incoming: Bool) {
//        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
//        
//        let rgbValue = name.hash
//        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
//        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
//        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
//        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
//        
//        let nameLength = countElements(name)
//        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(3, nameLength)))
//        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
//        
//        avatars[name] = userImage
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        inputToolbar.contentView.leftBarButtonItem = nil
//        automaticallyScrollsToMostRecentMessage = true
//        navigationController?.navigationBar.topItem?.title = "Logout"
//        
//        sender = (sender != nil) ? sender : "Anonymous"
//        let profileImageUrl = user?.providerData["cachedUserProfile"]?["profile_image_url_https"] as? NSString
//        if let urlString = profileImageUrl {
//            setupAvatarImage(sender, imageUrl: urlString, incoming: false)
//            senderImageUrl = urlString
//        } else {
//            setupAvatarColor(sender, incoming: false)
//            senderImageUrl = ""
//        }
//        
//        setupFirebase()
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        collectionView.collectionViewLayout.springinessEnabled = true
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if ref != nil {
//            ref.unauth()
//        }
//    }
//    
//    // ACTIONS
//    
//    func receivedMessagePressed(sender: UIBarButtonItem) {
//        // Simulate reciving message
//        showTypingIndicator = !showTypingIndicator
//        scrollToBottomAnimated(true)
//    }
//    
//    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
//        JSQSystemSoundPlayer.jsq_playMessageSentSound()
//        
//        sendMessage(text, sender: sender)
//        
//        finishSendingMessage()
//    }
//    
//    override func didPressAccessoryButton(sender: UIButton!) {
//        println("Camera pressed!")
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        return messages[indexPath.item]
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
//        let message = messages[indexPath.item]
//        
//        if message.sender() == sender {
//            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
//        }
//        
//        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
//        let message = messages[indexPath.item]
//        if let avatar = avatars[message.sender()] {
//            return UIImageView(image: avatar)
//        } else {
//            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
//            return UIImageView(image:avatars[message.sender()])
//        }
//    }
//    
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//    
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
//        
//        let message = messages[indexPath.item]
//        if message.sender() == sender {
//            cell.textView.textColor = UIColor.blackColor()
//        } else {
//            cell.textView.textColor = UIColor.whiteColor()
//        }
//        
//        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
//        cell.textView.linkTextAttributes = attributes
//        
//        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
//        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
//        return cell
//    }
//    
//    
//    // View  usernames above bubbles
//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        let message = messages[indexPath.item];
//        
//        // Sent by me, skip
//        if message.sender() == sender {
//            return nil;
//        }
//        
//        // Same as previous sender, skip
//        if indexPath.item > 0 {
//            let previousMessage = messages[indexPath.item - 1];
//            if previousMessage.sender() == message.sender() {
//                return nil;
//            }
//        }
//        
//        return NSAttributedString(string:message.sender())
//    }
//    
//    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        let message = messages[indexPath.item]
//        
//        // Sent by me, skip
//        if message.sender() == sender {
//            return CGFloat(0.0);
//        }
//        
//        // Same as previous sender, skip
//        if indexPath.item > 0 {
//            let previousMessage = messages[indexPath.item - 1];
//            if previousMessage.sender() == message.sender() {
//                return CGFloat(0.0);
//            }
//        }
//        
//        return kJSQMessagesCollectionViewCellLabelHeightDefault
//    }
}
