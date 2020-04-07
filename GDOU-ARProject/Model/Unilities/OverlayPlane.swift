//
//  OverlayPlane.swift
//  AREducationApp
//
//  Created by 刘友 on 2017/11/15.
//  Copyright © 2017年 刘友. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class OverlayPlane : SCNNode {
    
    var anchor :ARPlaneAnchor
    var planeGeometry :SCNPlane!
    var planeColor: UIColor
    
    init(anchor :ARPlaneAnchor, color: UIColor) {
        planeColor = color
        self.anchor = anchor
        super.init()
        setup(color: planeColor)
    }
    
    func update(anchor :ARPlaneAnchor) {
        
        self.planeGeometry.width = CGFloat(anchor.extent.x);
        self.planeGeometry.height = CGFloat(anchor.extent.z);
        //self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        self.simdPosition = float3(anchor.center.x, 0, anchor.center.z)
        
        let planeNode = self.childNodes.first!
        
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
    }
    
    private func setup(color: UIColor) {
        
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        // MARK: - Setup the material of planes
        let material = SCNMaterial()
        // Use image as planes' material
        //material.diffuse.contents = UIImage(named:"Models.scnassets/tron1.png")

        material.diffuse.contents = color
        
        self.planeGeometry.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2
        //planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);//这句同上一句等同
        
        // add to the parent
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




