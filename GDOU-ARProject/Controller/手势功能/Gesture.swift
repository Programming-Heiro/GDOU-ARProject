////
////  Gesture.swift
////  AREducationApp
////
////  Created by 刘友 on 2017/12/11.
////  Copyright © 2017年 刘友. All rights reserved.
////
//
///*
// Abstract:
// Manages gesture interactions with the AR scene.
// */

import UIKit
import SceneKit

extension ViewController {
    @objc func pinchRecognized(pinch :UIPinchGestureRecognizer) {
        currentlyVirtualObjectNode.runAction(SCNAction.scale(to: pinch.scale/20, duration: 0.2))
    }
    
    @objc func panRecognized(pan: UIPanGestureRecognizer) {
        
        let xPan = pan.velocity(in: sceneView).x/10000
        currentlyVirtualObjectNode.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("handleTap")
        
        let touchLocation: CGPoint = sender.location(in: sceneView)
        
        let touch = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        if let hitTest = hitTestResults.first {

            let hits = self.sceneView.hitTest(touchLocation, options: nil)
            let hitsList = hits.first
            let hitsObject = hitsList?.node
            if (!hits.isEmpty && hitsObject?.name == "virtualObject") {
                currentlyVirtualObjectNode = (hits.first?.node)!
                
                // get its material
                let material = currentlyVirtualObjectNode.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    material.emission.contents = UIColor.black
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.red
                SCNTransaction.commit()
                
            } else {

            currentlyVirtualObjectNode.position = SCNVector3(hitTest.worldTransform.columns.3.x,hitTest.worldTransform.columns.3.y,hitTest.worldTransform.columns.3.z)
                
            }
        }
    }
}
