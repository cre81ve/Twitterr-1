//
//  TwitterApi.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

//MARK : Base
let baseUrl =  "https://api.twitter.com"

//MARK : Auth
let consumerKey = "BmQBNNGFgMmm7QNLLufoS65iG"
let consumerSecret = "LaAyniGXUMZQZfnQcBm7u3t5gli1d4ahpFuu1H6rBOeKTdhpnp"
let appOnlyUrl = "/oauth2/token"
let requestTokenUrl = "/oauth/request_token"
let authorizeUrl = "/oauth/authorize"
let accessTokenUrl = "/oauth/access_token"
let accountVerifyUrl = "/1.1/account/verify_credentials.json"


//MARK : Tweets
let homeUrl = "/1.1/statuses/home_timeline.json"
let userUrl = "/1.1/users/lookup.json"

let retweetUrl = "/1.1/statuses/retweet/"
let createFavoriteUrl = "/1.1/favorites/create.json"
let listFavoriteUrl = "/1.1/favorites/list.json"
let tweetUrl = "/1.1/statuses/update.json"

//MARK : App Config
let appUrlOAuthCallback = "twitterr://oauth"
var globalTweets = [Tweet]()



class TwitterApi:BDBOAuth1SessionManager{
    
    static let shared = TwitterApi(baseURL: URL(string: baseUrl), consumerKey: consumerKey, consumerSecret: consumerSecret)

    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    
    
    
    //MARK : OAuth & Login
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure

        fetchRequestToken (withPath: requestTokenUrl, method: "GET", callbackURL: URL(string: appUrlOAuthCallback)! , scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            let authUrl = baseUrl + authorizeUrl + "?oauth_token=\(requestToken.token!)"
            let url = NSURL(string: authUrl)! as URL
            
            UIApplication.shared.open(url)
            
        }, failure: { (error: Error?) in
            self.loginFailure?(error!)
        })
    }
    
    func open(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: accessTokenUrl, method: "POST", requestToken: requestToken, success: { (accesToken: BDBOAuth1Credential?) in
            self.currentAccount(success: { (user: User) in
                User.me = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        },failure: { (error: Error?) in
            self.loginFailure?(error!)
        })
    }
    
    
    
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(accountVerifyUrl, parameters: nil, success: { (task, response) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            print("error verifying credentials")
            failure(error!)
        })
    }
    
    
    func verify(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(accountVerifyUrl, parameters: nil, success: { (task, response) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            failure(error!)
        })
    }
    
    
    func logout() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
        User.me = nil
        User._current = nil
        deauthorize()
    }
    

    func home(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get(homeUrl, parameters: parameters, success: { (task, response) in
            let dictionariesArray = response as! [NSDictionary]
            let tweets = Tweet.tweetsWith(dictionaryArray: dictionariesArray)
            success(tweets)
        }) { (task, error) in
            failure(error)
        }
    }
    
    
    func user(parameters: [String: AnyObject]? ,success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(homeUrl, parameters: parameters, success: { (task, response) in
            let dictionariesArray = response as! [NSDictionary]
            let usr = User(dictionary: dictionariesArray[0])
            success(usr)
        }) { (task, error) in
            failure(error)
        }
    }
    
    
 
    func tweet(parameters: [String: AnyObject]?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(tweetUrl, parameters: parameters, success: { (task, response) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }) { (task, error) in
            failure(error)
        }
    }
    
    
    func reTweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(retweetUrl + tweet.id!+".json", parameters: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError posting tweet1:: \(error) \n\n")
            failure(error)
        })
    }
    
    
    func favorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["id": tweet.id]
         post(createFavoriteUrl, parameters: parameters, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func saveTweets(tweets:[Tweet]){
        let tweetsData = NSKeyedArchiver.archivedData(withRootObject: tweets)
        UserDefaults.standard.set(tweetsData, forKey: "tweets")
    }
    
    func loadTweets() -> [Tweet]{
        let tweetsData = UserDefaults.standard.object(forKey: "tweets") as? NSData
        if let tweetsData = tweetsData {
            let tweetsArray = NSKeyedUnarchiver.unarchiveObject(with: tweetsData as Data) as? [Tweet]
            
            if let tweetsArray = tweetsArray {
                print("Count - \(tweetsArray.count)")
                return tweetsArray
            }
            
        }
        return [Tweet]()
    }
    
}

