//
//  TweetDetailController.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import AFNetworking
class TweetDetailController: UIViewController {
    @IBOutlet weak var retweetIconHeight: NSLayoutConstraint!

    @IBOutlet weak var retweetedHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favCount: UILabel!
    @IBOutlet weak var dateString: UILabel!
    @IBOutlet weak var tweetText: ActiveLabel!
    @IBOutlet weak var userProfileUrl: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userRetweeted: UILabel!
    @IBOutlet weak var favIcon: UIButton!
    
    @IBOutlet weak var retweetIcon: UIButton!
    var tweet:Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileUrl.setImageWith((tweet.userProfileImage)!)
        favCount.text = "\(tweet.favouritesCount)"
        retweetCount.text = "\(tweet.retweetCount)"
        
        makeRetweet(count: tweet.retweetCount)
        makeFavorite(count: tweet.favouritesCount)
        
        if let tweetedAt = tweet.tweetedDate {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            dateString.text = dateformatter.string(from: tweetedAt)
        }
        userName.text = tweet.userName
        userDisplayName.text = tweet.userScreenName
        if let retweeteduser = tweet?.retweetUserName {
            userRetweeted.text = retweeteduser + " retweeted"
            retweetedHeight.constant = 15
            retweetIconHeight.constant = 17

        } else{
            retweetedHeight.constant = 0
            retweetIconHeight.constant = 0
        }
        tweetText.customize { (label) in
            label.text = self.tweet.text
            label.numberOfLines = 0
            label.lineSpacing = 4
            label.sizeToFit()
            
            label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
            label.hashtagColor = UIColor(rgb: 0x4099FF)
            label.mentionColor = UIColor(rgb: 0x4099FF)
            label.URLColor = UIColor(rgb: 0x4099FF)
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
        }
        Style.styleNav(viewController: self)

        // Do any additional setup after loading the view.
    }

    
    func makeFavorite(count:Int) {
        if(count != 0) {
            self.favCount.text = "\(count)"
            if(tweet.favorited)!{
                self.favIcon.setImage(#imageLiteral(resourceName: "favred"), for: .normal)
            }
        }else{
            self.favCount.text = "0"
        }
    }
    
    
    func makeRetweet(count:Int) {
        if(count != 0) {
            self.retweetCount.text = "\(count)"
            if(tweet.retweeted)! {
                self.retweetIcon.setImage(#imageLiteral(resourceName: "retweetgreen"), for: .normal)
            }
        }else{
            self.retweetCount.text = "0"
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)

    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReplyDetail(_ sender: Any) {
        
        self.performSegue(withIdentifier: "replyFromDetail", sender: self)
    }

    @IBAction func onRetweetAction(_ sender: Any) {
        tweet.reTweet( success: { (tweetArg) in
            self.tweet.retweeted = true
            self.retweetIcon.setImage(#imageLiteral(resourceName: "retweetgreen"), for: .normal)
            var finalCount = self.tweet.retweetCount
            finalCount = finalCount+1
            self.retweetCount.text = "\(finalCount)"
        }, failure: { (error) in
            print("failed to favorite")
        })
        
    }
    @IBAction func onFavoriteDetail(_ sender: Any) {
        tweet.favorite( success: { (tweetArg) in
            self.tweet.favorited = true
            self.favIcon.setImage(#imageLiteral(resourceName: "favred"), for: .normal)
            var finalCount = self.tweet.favouritesCount
            finalCount = finalCount+1
            self.favCount.text = "\(finalCount)"

        }, failure: { (error) in
            print("failed to retweet")
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "replyFromDetail") {
            let tweetController = segue.destination as! TweetController
            tweetController.replyTo = tweet
            tweetController.delegate = self
            print("Navigating to reply")
        }
        
        
    }
    //retweetFromDetail
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TweetDetailController :  NewTweetProtocol {
    
    func onReplyOrNewTweet(tweet: Tweet) {
        
        
    }
    
    func onCancel() {
        
    }
}


