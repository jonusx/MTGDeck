//
//  OCRPreviewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/5/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit
import AVFoundation

protocol OCRResultsDelegate {
    func ORCController(controller:OCRPreviewController?, didProduceAnnotations annotations:[Annotation]?)
}

class OCRPreviewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var OCRImageView:UIImageView?
    @IBOutlet weak var selectButton:UIButton?
    @IBOutlet var loadingView:UIView?
    
    var annotations:[Annotation]?
    var delegate:OCRResultsDelegate?
    
    let searchQueue:NSOperationQueue = NSOperationQueue()
    var firstLoad = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if firstLoad == true {
            return
        }
        firstLoad = true
        
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    if granted {
                        self.showCamera()
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Camera Access", message: "Please allow access to the camera for visual search.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
                            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        self.showDetailViewController(alert, sender: self)
                    }
                })
                
            })
        case .Authorized:
            showCamera()
        case .Denied, .Restricted:
            print("No access")
        }
        print("blah")
    }
    
    @IBAction func showCamera() {
        OCRImageView?.image = nil
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func choose() {
        delegate?.ORCController(self, didProduceAnnotations: annotations)
        cancel()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        loadingView?.hidden = false
        dismissViewControllerAnimated(true, completion: {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.OCRImageView?.image = pickedImage
                    let imageOp = ImageSearchOperation(image: pickedImage)
                    imageOp.completionBlock = { [weak imageOp] in
                        guard let imageOp = imageOp else { return }
                        if let taggedImage = imageOp.taggedImage {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.OCRImageView?.image = taggedImage
                                self.annotations = imageOp.annotations
                                self.selectButton?.hidden = false
                                self.loadingView?.hidden = true
                            })
                        }
                    }
                    self.searchQueue.addOperation(imageOp)
            }
        })
        
    }
}
