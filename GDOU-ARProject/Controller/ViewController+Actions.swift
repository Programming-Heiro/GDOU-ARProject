//
//  ViewController+Actions.swift
//  AREducationApp
//
//  Created by 刘友 on 2018/4/14.
//  Copyright © 2018年 刘友. All rights reserved.
//

import Foundation
import UIKit
import ARKit


extension ViewController: UIPopoverPresentationControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopoverMenu"
        {
            let popoverViewController = segue.destination
            popoverViewController.popoverPresentationController?.delegate = self
            
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    // Remove all the object from scene view and restart AR session
    @IBAction func RemoveAllObjects(_ sender: UIButton) {
        removeAllVirtualObjects()
        
        DispatchQueue.main.async {
            self.setupFocusSquare()
            
            let configuration = self.sceneView.session.configuration as! ARWorldTrackingConfiguration
            self.sceneView.session.pause()
            self.sceneView.session.run(configuration, options: .resetTracking)
        }
        
    }
}
