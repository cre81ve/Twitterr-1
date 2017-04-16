//
//  TweetController.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit


protocol NewTweetProtocol  {
    func onReplyOrNewTweet(tweet:Tweet)
    func onCancel()
}


class TweetController: UIViewController {

    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var remainingCharacters: UILabel!
    

    var replyTo:Tweet?
    var isReply:Bool = false
    var replyToID:String?
    var replyToUserName:String?
    var delegate:NewTweetProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetText.delegate = self
        userName.text = User._current?.name
        userDisplayName.text  = User._current?.screenName
        userImage.setImageWith((User._current?.profileImageUrl)!)
        
        if let replyToUser = replyTo?.userName {
            tweetText.text = "@\(replyToUser) "
            isReply = true
            replyToID = replyTo?.id
            countDown()
        }
        Style.styleNav(viewController: self)
        tweetText.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tweet(_ sender: Any) {
        var parameters = ["status":tweetText.text ]
        //replying a tweet.
        if(isReply) {
            parameters["in_reply_to_status_id"] = replyToID
        }
        Tweet.tweet(parameters: parameters as [String : AnyObject], success: { (postedTweet) in
            
            if(self.isReply) {
                postedTweet.text = "Replying to " + postedTweet.text!
            }

            if let delegate = self.delegate  {
                delegate.onReplyOrNewTweet(tweet: postedTweet)
            }
            
            let nc = NotificationCenter.default
            nc.post(name:NSNotification.Name(rawValue: Tweet.userDidRetweeted),
                    object: nil,
                    userInfo:["tweet":postedTweet])

            self.performSegue(withIdentifier: "toTweetsTable", sender: self)
            self.replyTo = nil

        }, failure: { (error) in
            print("Error in tweetin \(error.localizedDescription)")
            self.replyTo = nil
        })
       
        
    }
    @IBAction func cancel(_ sender: Any) {
       self.navigationController?.popViewController(animated: true)
       replyTo = nil
        if let delegate = self.delegate  {
            delegate.onCancel()
        }
    }

    
    var onefortytext = ""
    
    func countDown() {
        let tweetText = self.tweetText.text!
        let allowed = 140
        let currentCount = tweetText.characters.count
        var remaining = allowed - currentCount
        if(remaining == 0) {
            onefortytext = self.tweetText.text!
        }
        if(currentCount <= 3) {
            remainingCharacters.textColor = UIColor.black
        }
        if remaining <= 0 {
            remaining = 0
            postButton.isEnabled = false
            remainingCharacters.textColor = UIColor.red
             self.tweetText.text  = onefortytext
        }else {
            remainingCharacters.textColor = UIColor.gray
            postButton.isEnabled = true
        }
        remainingCharacters.text = "\(remaining)"
    }


}

extension TweetController:UITextViewDelegate  {
    
    
    func textViewDidChange(_ textView: UITextView) {
        countDown()
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        <#code#>
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        <#code#>
//    }
}
