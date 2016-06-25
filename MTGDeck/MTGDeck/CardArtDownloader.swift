//
//  CardArtDownloader.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/22/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CardArtDownloader {
    typealias ArtCompletion = (UIImage? -> ())
    enum DownloadStatus {
        case Ready, InProgress, Complete
    }
    var cache:[NSURL : DownloadStatus] = [:]
    var pendingCompletions:[NSURL : [ArtCompletion]] = [:]
    let cacheQueue:NSOperationQueue = NSOperationQueue()
    let imagesURL:NSURL = NSURL(string: "http://gatherer.wizards.com/Handlers/Image.ashx")!
    
    init() {
        cacheQueue.maxConcurrentOperationCount = 1 // Don't race condiditons
    }
    
    func downloadImageFrom(url:NSURL, completion:ArtCompletion) {
        cacheQueue.addOperationWithBlock {
            var completions:[ArtCompletion] = self.pendingCompletions[url] ?? []
            completions.append(completion)
            self.pendingCompletions[url] = completions
            
            if let status = self.cache[url] where status == .InProgress { // It's downloading.
                return
            }
            
            self.cache[url] = .InProgress
            
            NSURLSession.sharedSession().downloadTaskWithRequest(NSURLRequest(URL: url)) { (fileUrl, response, error) in
                self.cacheQueue.addOperationWithBlock({
                    guard let urlCheck = fileUrl, data = NSData(contentsOfURL:urlCheck), downloadedImage = UIImage(data: data) else {
                        self.cache[url] = nil
                        self.completeForURL(url, image: nil)
                        return
                    }
                    self.cache[url] = .Complete
                    self.completeForURL(url, image: downloadedImage)
                })
                }.resume()
        }
    }
    
    func completeForURL(url:NSURL, image:UIImage?) {
        if let pendingCompletions = self.pendingCompletions[url] {
            for completionBlock in pendingCompletions {
                completionBlock(image)
            }
        }
        self.pendingCompletions[url] = nil
    }

}

extension CardArtDownloader {
    func artForCard(card:MTGCard, completion:ArtCompletion) {
        let urlComponents = NSURLComponents(URL: imagesURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [NSURLQueryItem(name: "multiverseid", value:String(card.multiverseid!)), NSURLQueryItem(name:"type", value: "card")]
        downloadImageFrom(urlComponents!.URL!, completion: completion)
    }
}

