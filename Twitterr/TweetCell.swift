//
//  TweetCell.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit


protocol RetweetProtocol  {
    func onRetweet(tweet:Tweet)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetedIconHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetedHeight: NSLayoutConstraint! //15
    @IBOutlet weak var favHeart: UIButton!
    
    @IBOutlet weak var userProfileImageUrl: UIImageView!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var reTweetCount: UILabel!
    @IBOutlet weak var tweetText: ActiveLabel!
    @IBOutlet weak var tweetedAgo: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRetweeted: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetStack: UIStackView!
    @IBOutlet weak var favStack: UIStackView!
    var delegate:RetweetProtocol?

    var tweet:Tweet!  {
        didSet {
            
            if(tweet != nil) {
                tweetText.customize { (label) in
                    label.text = tweet.text
                    if let replyuser = tweet.replyUser?.name  {
                        label.text = "Replying to @\(replyuser)" + tweet.text!
                    }
                    label.numberOfLines = 0
                    label.lineSpacing = 1
                    label.hashtagColor = UIColor(rgb: 0x4099FF)
                    label.mentionColor = UIColor(rgb: 0x4099FF)
                    label.URLColor = UIColor(rgb: 0x4099FF)
                    label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
                }
                
                userName.text = tweet?.userScreenName
                
                userId.text = tweet?.userName
                userProfileImageUrl.setImageWith((tweet?.userProfileImage)!)
                userProfileImageUrl.layer.cornerRadius = 5
                userProfileImageUrl.clipsToBounds = true


                if let retweeteduser = tweet?.retweetUserName {
                    userRetweeted.text = retweeteduser + " retweeted"
                    retweetedIconHeight.constant = 17
                    retweetedHeight.constant = 15
                }else{
                    retweetedIconHeight.constant = 0
                    retweetedHeight.constant = 0
                }
                
                var retweetedCount = 0
                if( tweet.retweetCount != 0) {
                    retweetedCount = tweet.retweetCount
                }
                var favCount = 0
                if( tweet.favouritesCount != 0) {
                    favCount = tweet.favouritesCount
                }
                
                
                favoriteCount.text = favCount != 0 ? "\(favCount)" :""
                reTweetCount.text = retweetedCount != 0 ? "\(retweetedCount)" :""
                
                if(tweet.favorited)! {
                    makeFavorite(count: favCount)
                }
                if(tweet.retweeted)! {
                    makeRetweet(count: retweetedCount)
                }
                tweetedAgo.text = "•\(tweet?.timeAgo ?? "")"
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        accessoryType = .none
        userName.sizeToFit()


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    @IBAction func onReply(_ sender: Any) {
        if(delegate != nil ) {
            delegate?.onRetweet( tweet: tweet)
        }
    }
    
    @IBAction func onFav(_ sender: Any) {

        tweet.favorite(success: { (tweetArg) in
            var finalCount = 0
            if let currentCount = self.favoriteCount.text {
                var currentCountInt = Int(currentCount)
                if(currentCountInt == nil) {
                    currentCountInt = 0
                }
                finalCount = currentCountInt!+1
            }
            self.makeFavorite(count: finalCount)
            
        }, failure: { (error) in
            print("Error in favorite \(error.localizedDescription)")
        })
        
    }
    
    func makeFavorite(count:Int) {
        self.favoriteCount.textColor = UIColor.red
        if(count != 0) {
            self.favoriteCount.text = "\(count)"
            self.favHeart.setImage(#imageLiteral(resourceName: "favred"), for: .normal)

        }else{
            self.favoriteCount.text = ""
        }
    }
    
    
    func makeRetweet(count:Int) {
        self.reTweetCount.textColor = UIColor.green
        if(count != 0) {
            self.reTweetCount.text = "\(count)"
            self.retweetButton.setImage(#imageLiteral(resourceName: "retweetgreen"), for: .normal)

        }else{
            self.reTweetCount.text = ""
        }
    }
    
    
    @IBAction func onRetweet(_ sender: Any) {
        tweet.reTweet(success: { (tweetArg) in
            self.tweet.retweeted = true
            var finalCount = 0
            if let currentCount = self.reTweetCount.text {
                var currentCountInt = Int(currentCount)
                if(currentCountInt == nil) {
                    currentCountInt = 0
                }
                finalCount = currentCountInt!+1
            }
            self.makeRetweet(count: finalCount)
        }, failure: { (error) in
            print("failed to retweet")
        })
    }
    
    override func prepareForReuse() {
        tweet = nil
        self.favoriteCount.text = ""
        self.reTweetCount.text = ""
        self.favHeart.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        self.reTweetCount.textColor = UIColor.gray
        self.favoriteCount.textColor = UIColor.gray
    }

}
