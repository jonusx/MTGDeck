//
//  ImageSearchOperation.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/4/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

struct Annotation {
    let path:UIBezierPath
    let text:String
    init?(dictionary:[NSObject : AnyObject?]) {
        guard let pointDictionary = dictionary["boundingPoly"] as? NSDictionary,
        verts = pointDictionary["vertices"] as? [NSDictionary],
        description = dictionary["description"] as? String else { return nil }
        text = description
        let box = UIBezierPath()
        for (index, vert) in verts.enumerate() {
            if let x = vert["x"] as? Int, y = vert["y"] as? Int {
                let point = CGPoint(x: x, y: y)
                if index == 0 {
                    box.moveToPoint(point)
                }
                else
                {
                    box.addLineToPoint(point)
                }
            }
        }
        box.closePath()
        path = box
    }
    
}

class ImageSearchOperation: NSOperation {
    private(set) var image:UIImage?
    private(set) var annotations:[Annotation]?
    private(set) var error:NSError?
    var taggedImage:UIImage?
    
    
    init(image:UIImage) {
        self.image = image
    }
    
    override var executing: Bool {
        return taggedImage == nil
    }
    
    override var finished: Bool {
        return taggedImage != nil
    }
    
    override func main() {
        let binaryImageData = base64EncodeImage(image!)
        createRequest(binaryImageData)
    }
    
    func resizeImage(imageSize: CGSize, image: UIImage) -> UIImage {
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(CIImage(image:image), forKey: "inputImage")
        filter.setValue(800/image.size.width, forKey: "inputScale")
        filter.setValue(1.0, forKey: "inputAspectRatio")
        let outputImage = filter.outputImage
        
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        return UIImage(CGImage: context.createCGImage(outputImage!, fromRect: outputImage!.extent))
    }
    
    func applyAnnotations(annotations:[Annotation]) {
        UIGraphicsBeginImageContext(image!.size)
        let context = UIGraphicsGetCurrentContext()
        image!.drawInRect(CGRectMake(0, 0, image!.size.width, image!.size.height))
        CGContextSetLineWidth(context, 2.0)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        let path = UIBezierPath()
        for annotation in annotations { // Building the paths for the text
            path.appendPath(annotation.path)
        }
        CGContextAddPath(context, path.CGPath)
        CGContextStrokePath(context)
        taggedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            self.image = resizeImage(newSize, image: image)
            imagedata = UIImagePNGRepresentation(self.image!)
        }
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func createRequest(imageData: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyCPtF1ubv8SHbRMBt4NLCDn--_b-QVc-M0")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue( NSBundle.mainBundle().bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 60
                    ]
                ]
            ]
        ]
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        let sema = dispatch_semaphore_create(0)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary,
            responses = json["responses"] as? [NSDictionary],
                annotationsArray = responses[0]["textAnnotations"] as? [NSDictionary] else {
                    self.error = NSError(domain: "Fetch", code: 9999, userInfo: nil)
                    dispatch_semaphore_signal(sema)
                    return
            }
            self.annotations = annotationsArray.flatMap({ Annotation(dictionary: $0 as [NSObject : AnyObject]) })
            if self.annotations != nil && self.annotations!.count > 0 {
                self.applyAnnotations(self.annotations!)
            }
            dispatch_semaphore_signal(sema)
            }.resume()
        dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, Int64(30 * NSEC_PER_SEC)))
    }

}
