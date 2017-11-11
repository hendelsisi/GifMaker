//
//  UserDefaultsManager.swift
//  MusicPlayer
//
//  Created by Minas Kamel on 8/16/15.
//  Copyright (c) 2015 nWeave LLC. All rights reserved.
//

import Foundation

class UserDefaultsManager
{
 
    static let instance = UserDefaultsManager()
    
    func saveObject(_ object : AnyObject, key : String)
    {
        let defaults =  UserDefaults.standard
        defaults.set(object, forKey: key)
        defaults.synchronize()
    }
    
    func getObjectForKey(_ key : String) -> AnyObject?
    {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key) as AnyObject?
    }
    
    func removeObject(_ key : String) {
        if getObjectForKey(key) != nil {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }
    }
    
}
