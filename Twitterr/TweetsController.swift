//
//  TweetsController.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import AFNetworking
import ICSPullToRefresh
import MBProgressHUD

protocol RefreshAndLoadProtocol  {
    func refreshEnded()
    func infiniteScroll()
}



class TweetsController: UIViewController {

    
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var tweetsTable: UITableView!
    
    var tweets:[Tweet]?
    var reply:Tweet?
    var parameters:[String:Any?] = ["count": 20]
    
    //MARK : ViewController methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTweetsTable()
        Style.styleNav(viewController: self)
        observeReplies()
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        tweetsTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            //refresh control height is 60.
            self.tweetsTable.contentInset = UIEdgeInsetsMake( y-60, 0, 0, 0)
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterApi.shared?.logout()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tweetDetail") {
            let detailController = segue.destination as! TweetDetailController
            let indexPath = sender as! IndexPath
            detailController.tweet = tweets?[(indexPath.row)]
        }
        if (segue.identifier == "retweetFromTable") {
            let tweetController = segue.destination as! TweetController
            tweetController.replyTo = reply
            tweetController.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK : Tweet Changes and Action

    
    func observeReplies() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Tweet.userDidRetweeted), object: nil, queue: OperationQueue.main) { (Notification) in
            if let userInfo  = Notification.userInfo {
                let tweet = userInfo["tweet"] as! Tweet
                self.tweets?.insert(tweet, at: 0)
                self.tweetsTable.reloadData()
            }
        }
    }
    
    func refreshTweets() {
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
    }
    
    func moreTweets() {
        parameters["max_id"] = Tweet.lastTweetId!
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: true)
    }
    
    func getTweets(parameters: [String:AnyObject],progress:Bool ,isMore:Bool) {
        if(progress){
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        Tweet.home(parameters: parameters as [String : AnyObject], success: { (newtweets) in
            if(isMore){
                //Twitter api gives - max_id inclusive in more.
                var newFilterTweets = newtweets
                newFilterTweets.remove(at: 0)
                self.tweets = self.tweets! + (newFilterTweets)
            }else {
                self.tweets = newtweets
            }
            self.tweetsTable.reloadData()
            if(progress) {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            self.tweetsTable.infiniteScrollingView?.stopAnimating()
            
        }, failure: { (error) in
            print("error \(error.localizedDescription)")
            self.tweetsTable.infiniteScrollingView?.stopAnimating()
            
        })
    }
    
    
  }


//MARK : Tweets Table

extension TweetsController : UITableViewDelegate ,UITableViewDataSource {
    
    func initializeTweetsTable() {
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        tweetsTable.estimatedRowHeight = 100
        tweetsTable.addPullToRefreshHandler {
            self.refreshEnded()
        }
        tweetsTable.addInfiniteScrollingWithHandler {
            self.infiniteScroll()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  tweetCell = tableView.dequeueReusableCell(withIdentifier: "tweetsCell") as! TweetCell
        let tweet = tweets?[indexPath.row]
        tweetCell.tweet = tweet
        tweetCell.delegate = self
        return tweetCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "tweetDetail", sender: indexPath)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentTweets = tweets {
            return currentTweets.count
        }
        return 0
    }
}


//MARK : Reload and infinite scroll.

extension TweetsController:RefreshAndLoadProtocol {
    
    func refreshEnded() {
        DispatchQueue.global(qos: .userInitiated).async{
            sleep(1)
            self.refreshTweets()
            DispatchQueue.main.async { [unowned self] in
                self.tweetsTable.pullToRefreshView?.stopAnimating()
            }
        }
    }
    
    func infiniteScroll() {
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)
            self.moreTweets()
            DispatchQueue.main.async { [unowned self] in
                self.tweetsTable.pullToRefreshView?.stopAnimating()
            }
        }
    }
    

}


extension TweetsController : RetweetProtocol , NewTweetProtocol {

    func onRetweet(tweet: Tweet) {
        reply = tweet
        self.performSegue(withIdentifier: "retweetFromTable", sender: self)
    }
    
    func onReplyOrNewTweet(tweet: Tweet) {
        tweets?.insert(tweet, at: 0)
        self.tweetsTable.reloadData()
        reply = nil
    }
    
    func onCancel() {
        reply = nil
    }
}
    


