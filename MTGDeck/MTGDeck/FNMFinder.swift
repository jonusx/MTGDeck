//
//  FNMFinder.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/31/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import SafariServices

class FNMFinder: UIViewController {
    @IBOutlet weak var webview:UIWebView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webview?.loadRequest(NSURLRequest(URL: NSURL(string:"http://locator.wizards.com/#brand=magic")!))
    }

}
