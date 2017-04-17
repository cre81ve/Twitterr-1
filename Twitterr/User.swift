//
//  User.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation

class User: NSObject {
    var idStr:String?
    var name: String?
    var screenName: String?
    var profileImageUrl: URL?
    var tagLine: String?
    var dictionary: NSDictionary?
    
    static let currentUserDataKey = "currentUserData"
    static let userDidLogoutNotification = "UserDidLogout"
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        self.idStr = dictionary["id_str"] as? String
        name = dictionary["screen_name"] as? String
        screenName = dictionary["name"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileImageUrl = NSURL(string: profileUrlString)! as URL
        }
        
        tagLine = dictionary["description"] as? String
    }
    
    static var _current: User?
    
    class var me: User? {
        get{
            if _current == nil {
                let defaults = UserDefaults.standard
                let userData =  defaults.object(forKey: currentUserDataKey) as? Data
                if let userData = userData {
                    let dictionary = NSKeyedUnarchiver.unarchiveObject(with: userData)
                    if(dictionary != nil){
                        _current = User.init(dictionary: dictionary as! NSDictionary)
                    }else{
                        TwitterApi.shared?.logout()
                    }
                }
            }
            return _current
        }
        set(user){
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = NSKeyedArchiver.archivedData(withRootObject: user.dictionary!)
                defaults.set(data, forKey: currentUserDataKey)
            }
            else {
                defaults.set(nil, forKey: currentUserDataKey)
            }
            
            defaults.synchronize()
        }
    }
    
}
