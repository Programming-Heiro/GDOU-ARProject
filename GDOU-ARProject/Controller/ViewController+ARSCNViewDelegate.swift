//
//  ViewController+ARSCNViewDelegate.swift
//  AREducationApp
//
//  Created by 刘友 on 2017/11/23.
//  Copyright © 2017年 刘友. All rights reserved.
//

import Foundation
import ARKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    // MARK: - ARSCNViewDelegate

    // didAdd
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        // When detected new anchors, add the anchors into previous planes
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = OverlayPlane(anchor: planeAnchor, color: planesColor)
        self.planes.append(plane)
        node.addChildNode(plane)

    }
    
    // didUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let planefilter = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if planefilter == nil {
            return
        }
        
        // When detected new anchors, delete old anchors and add new anchors into the plane so that the planes can keep updating and accuracy.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        let plane = OverlayPlane(anchor: planeAnchor, color: planesColor)
        self.planes.append(plane)
        node.addChildNode(plane)
        // update planes
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    // updateAtTime
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    // didRemove
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
    }
    
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Set the sessinInfoLabel
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        
        var message: String {
            switch trackingState {
            case .normal where frame.anchors.isEmpty:
                return "请在水平表面移动设备"
            case .normal:
                return ""
            case .notAvailable:
                return "检测功能不可用"
            case .limited(.excessiveMotion):
                return "检测失败：请缓慢地移动您的设备"
            case .limited(.insufficientFeatures):
                return "检测失败：检测表面细节不清晰"
            case .limited(.initializing):
                return "正在检测平面"
            case .limited(.relocalizing):
                return "恢复中断"
            }
        }
        
        sessionInfoLabel.text = message

        if (message.isEmpty) {
            sessionInfoLabel.text = "检测成功，请选择模型"
        }
        
    }

}
