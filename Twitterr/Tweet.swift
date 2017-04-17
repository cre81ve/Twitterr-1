//
//  Tweet.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation




class Tweet: NSObject, NSCoding {

    var text: String?
    var retweetCount: Int = 0
    var favouritesCount: Int = 0
    var tweetedDate: Date?
    var id: String?

    var userName: String?
    var userScreenName: String?
    var userProfileImage: URL?
    var retweeted: Bool?
    var favorited: Bool?
    var retweetedStatus:NSDictionary?
    var retweetUserName: String?
    var retweetUserScreenName: String?
    var timeAgo:String?
    var inReplyToUser:String?
    var replyUser:User?
    var retweetedId:String?
    
    //for pagination
    static var lastTweetId:String?
    //for notification
    static var userDidRetweeted = "userRetweeted"

    public func encode(with aCoder: NSCoder) {
        
    }
    
   static let api = TwitterApi.shared

    public required init?(coder aDecoder: NSCoder) {
        
    }
    

    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favouritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        let timeStampString = dictionary["created_at"] as? String
        if let timeStampString = timeStampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            tweetedDate = formatter.date(from: timeStampString)
            let dateFormatter = DateFormatter()
            timeAgo = dateFormatter.tiwtterTimeSince(from: tweetedDate! as NSDate)
        }
        
        id = dictionary["id_str"] as? String
        
        retweeted = dictionary["retweeted"] as? Bool ?? false
        favorited = dictionary["favorited"] as? Bool ?? false
        let inreplyTouser = dictionary["in_reply_to_user_id_str"] as?  String
        if inreplyTouser != nil {
            self.inReplyToUser = inreplyTouser
        }
        let retweetStatus = dictionary["retweeted_status"] as? NSDictionary
        if retweetStatus != nil {
            self.retweetedStatus = retweetStatus
            let user = retweetStatus?["user"] as? NSDictionary
            userName = user?["screen_name"] as? String
            userScreenName = user?["name"] as? String
            let profileImage = user?["profile_image_url_https"] as? String
            userProfileImage = URL(string: profileImage!)
            let retweetUser = dictionary["user"] as? NSDictionary
            retweetUserName = retweetUser?["screen_name"] as? String
            retweetUserScreenName = retweetUser?["name"] as? String
            retweetedId = retweetStatus?["id_str"] as? String
        }
        else {
            let user = dictionary["user"] as? NSDictionary
            if user != nil
            {
                userName = user?["screen_name"] as? String
                userScreenName = user?["name"] as? String
                let profileImage = user?["profile_image_url_https"] as? String
                userProfileImage = URL(string: profileImage!)
            }
        }
        
    }

    class func tweetsWith(dictionaryArray: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = []
        
        for dictionary in dictionaryArray {
            let tweet = Tweet(dictionary: dictionary)
            if tweet.inReplyToUser != nil {
                let parameters = ["user_id" : tweet.inReplyToUser]
                Tweet.user(parameters: parameters as [String : AnyObject], success: { (replyuser) in
                    tweet.replyUser = replyuser
                }, failure: { (error) in
                    print("Error in retrieving in reply user")
                })
            }
            tweets.append(tweet)
            lastTweetId = tweet.id
        }
        return tweets
    }

    func favorite(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.favorite(tweet: self, success: { (tweetArg) in
               success(tweetArg)
        }, failure: { (error) in
                failure(error)
        })
    }
    
    func unfavorite(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.unfavorite(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }


    func reTweet(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.reTweet(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func unReTweet(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.getAndUnRetweet(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    class func home(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.home(parameters: parameters!, success: { (newtweets) in
                    success(newtweets)
            }, failure: { (error) in
                 failure(error)
        })
    }

    
    class func tweet(parameters: [String: AnyObject]?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.tweet(parameters: parameters!, success: { (postedTweet) in
            success(postedTweet)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    class func user(parameters: [String: AnyObject]?, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.user(parameters: parameters!, success: { (gotuser) in
            success(gotuser)
        }, failure: { (error) in
            failure(error)
        })
    }
    
   }
