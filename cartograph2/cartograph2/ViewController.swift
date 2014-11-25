//
//  ViewController.swift
//  cartograph2
//
//  Created by Jed Lau on 11/25/14.
//  Copyright (c) 2014 Jed Lau. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, PHPhotoLibraryChangeObserver {
    let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch PHPhotoLibrary.authorizationStatus() {
        case PHAuthorizationStatus.NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status == PHAuthorizationStatus.Authorized {
                    self.photoLibrary.registerChangeObserver(self)
                    self.fetchAssets()
                }
            })

        case PHAuthorizationStatus.Authorized:
            self.photoLibrary.registerChangeObserver(self)
            self.fetchAssets()
            
        default:
            // Show an alert.
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    
    func fetchAssets() {
        let fetchResult = PHAsset.fetchAssetsWithOptions(nil)
        if fetchResult.firstObject == nil {
            NSLog("Error: asset not fetched")
            return
        }
        let asset = fetchResult.firstObject! as PHAsset
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(changeInfo: PHChange!) {
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            NSLog("PhotoLibrary: Asset changed")
        })
    }
}

