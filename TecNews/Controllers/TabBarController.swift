//
//  TabBarController.swift
//  TecNews
//
//  Created by Bruno Lemgruber on 27/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import RealmSwift

class TabBarController: UITabBarController {

    var articles:Results<RealmArticle>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        badgeBookmark()
    }
    
    func badgeBookmark(){
        articles = realm.objects(RealmArticle.self)
        if let articlesRealm = articles{
            if articlesRealm.count > 0{
                self.viewControllers![1].tabBarItem.badgeValue = "\(articlesRealm.count)"
            }else{
                self.viewControllers![1].tabBarItem.badgeValue = nil
            }
        }
    }
}
