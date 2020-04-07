//
//  ViewController.swift
//  AREducationApp
//
//  Created by 刘友 on 2017/11/15.
//  Copyright © 2017年 刘友. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var planeVisualSwitch: UISwitch!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sessionInfoView: UIView!
    
    var planes = [OverlayPlane]()
    var planesColor = UIColor.clear
    
    var focusSquare = FocusSquare()
    var EmptyNodeInFocusSquare = SCNNode()
    
    var dragOnInfinitePlanesEnabled = false
    
    // MARK: - ARKit Config Properties
    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    var VirtualObjectName: String = "Nothing" {
        didSet {
            focusSquare.planeNode.addChildNode(EmptyNodeInFocusSquare)
        }
        willSet {
            EmptyNodeInFocusSquare.removeFromParentNode()
        }
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func showingButton(_ sender: UIButton) {
        if settingsButton.isSelected == true {
            settingsButton.isSelected = false
            settingsButton.setImage(UIImage(named: "settingsPressed"), for: UIControlState.normal)
            print("hello")
        } else {
        }
    }
    
    @IBOutlet weak var virtualObjectsMenu: UIButton!
    @IBAction func chooseObject(_ button: UIButton) {
        
        let rowHeight = 45
        let popoverSize = CGSize(width: 250, height: rowHeight * VirtualObjectSelectionViewController.COUNT_OBJECTS)
        
        let objectViewController = VirtualObjectSelectionViewController(size: popoverSize)
        objectViewController.delegate = self
        objectViewController.modalPresentationStyle = .popover
        objectViewController.popoverPresentationController?.delegate = self
        self.present(objectViewController, animated: true, completion: nil)
        
        objectViewController.popoverPresentationController?.sourceView = button
        objectViewController.popoverPresentationController?.sourceRect = button.bounds
        
        if virtualObjectsMenu.isSelected == true {
            virtualObjectsMenu.isSelected = false
            virtualObjectsMenu.setImage(UIImage(named: "model_manage_selected_button"), for: UIControlState.normal)
        } else {
        }
    }
    
    @IBAction func addObject(_ sender: UIButton) {

        // Get the scene the model is stored in
        guard let modelScene = SCNScene(named: "\(VirtualObjectName)"+".scn", inDirectory: "Models.scnassets/"+"\(VirtualObjectName.lowercased())"+"_model")
            else {
                print("导入失败，未选择模型： \(VirtualObjectName)")
                return
        }
        
        // Get the model from the root node of the scene
        let modelNode = modelScene.rootNode.childNode(withName:"\(VirtualObjectName)", recursively: true)!
        
        modelNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
        modelNode.light?.type = .ambient
        modelNode.light?.color = UIColor.darkGray
        
        modelNode.position = focusSquare.position
        modelNode.name = "virtualObject"
        
        currentlyVirtualObjectNode = modelNode
        self.sceneView.scene.rootNode.addChildNode(currentlyVirtualObjectNode)

    }

    
    @IBAction func deleteSelectedObject(_ sender: UIButton) {
        let fadeOut = SCNAction.fadeOut(duration: 0.5)
        let remove = SCNAction.removeFromParentNode()
        let groupDeleteActions = SCNAction.sequence([fadeOut,remove])
        //currentlyVirtualObjectNode.removeFromParentNode()
        currentlyVirtualObjectNode.runAction(groupDeleteActions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show the debug imformation
        sceneView.showsStatistics = true
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Set up content
        setupCamera()
        setupFocusSquare()
        focusSquare.planeNode.addChildNode(EmptyNodeInFocusSquare)
        Setting.registerDefaults()

        /*
         The `sceneView.automaticallyUpdatesLighting` option creates an
         ambient light source and modulates its intensity. This sample app
         instead modulates a global lighting environment map for use with
         physically based materials, so disable automatic lighting.
         */
        self.sceneView.automaticallyUpdatesLighting = true
        
        if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
            sceneView.scene.lightingEnvironment.contents = environmentMap
        }
        
        // Add ambient light
        self.sceneView.autoenablesDefaultLighting = true
        
        // MARK - Gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(pan:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:
            #selector(pinchRecognized(pinch:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        
        self.view.addGestureRecognizer(pinchGesture)
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        debugPrint(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSettings()
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        //Prevent the screen gets dark
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run(standardConfiguration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Scene content setup

    func setupCamera() {
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        
        /*
         Enable HDR camera settings for the most realistic appearance
         with environmental lighting and physically based materials.
         */
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }

    
    func createVirtualObject(hitPosition: matrix_float4x4, sceneView: ARSCNView, virtualObjectNode: SCNNode, virtualObjectName: String) {
        
        virtualObjectNode.position = SCNVector3(hitPosition[3].x, hitPosition[3].y, hitPosition[3].z)
        
        // Create a new scene for each model
        guard let virtualObjectScene = SCNScene(named: "\(virtualObjectName)"+".scn", inDirectory: "Models.scnassets/"+"\(virtualObjectName.lowercased())"+"_model")
            else {
                print("找不到该模型： \(virtualObjectName)")
                return
        }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        virtualObjectNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(virtualObjectNode)
        
    }
    
    
    /*
     命名规则：
     .scn文件:大小写随意
     文件夹:全小写_model
     总节点：同scn
     */
    
    var currentlyVirtualObjectNode = SCNNode()
    
    func removeAllVirtualObjects() {
        for object in sceneView.scene.rootNode.childNodes {
            object.removeFromParentNode()
        }
    }
    func removeObjectFromFoucusSquare(_ FocusSqure: SCNNode, removedNodeName: SCNNode) {
        removedNodeName.removeFromParentNode()
    }
    
    func toggleAmbientLightEstimation(_ enabled: Bool) {
        if enabled {
            if !standardConfiguration.isLightEstimationEnabled {
                standardConfiguration.isLightEstimationEnabled = true
                session.run(standardConfiguration)
            }
        } else {
            if standardConfiguration.isLightEstimationEnabled {
                standardConfiguration.isLightEstimationEnabled = false
                session.run(standardConfiguration)
            }
        }
    }
    
    // Debug Visualization
    var showDebugVisuals: Bool = UserDefaults.standard.bool(for: .debugMode) {
        didSet {
            if (showDebugVisuals == true) {
                sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
            } else {
                sceneView.debugOptions = []
            }
            UserDefaults.standard.set(showDebugVisuals, for: .debugMode)
        }
    }
    
    // Detected Planed Visible
    var detectedPlanesVisuals: Bool = UserDefaults.standard.bool(for: .detectedPlanesVisible) {
        didSet {
            
            if (detectedPlanesVisuals == true) {
                for plane in self.planes {
                    plane.planeGeometry.materials.forEach { material in
                        material.diffuse.contents = UIColor(red: 65, green: 105, blue: 225, alpha: 0.5)
                    }
                    planesColor = UIColor(red: 65, green: 105, blue: 225, alpha: 0.5)
                }
            }else {
                for plane in self.planes {
                    plane.planeGeometry.materials.forEach { material in
                        material.diffuse.contents = UIColor.clear
                    }
                }
                planesColor = UIColor.clear
            }
        }
    }
    
    // SettingsMenu中关于三个手势的开关功能测试不成功，请后续跟进
    
    // Tap to Move
    var panGestureEnable: Bool = UserDefaults.standard.bool(for: .moveWithPanGesture) {
        didSet {
            UserDefaults.standard.set(panGestureEnable, for: .moveWithPanGesture)
            if panGestureEnable {
                print("on")
            } else {
                print("off")
            }
        }
        willSet {
            togglePanGestureEnable(panGestureEnable)
        }
    }
    func togglePanGestureEnable(_ enable: Bool) {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))

        if enable {
            self.view.addGestureRecognizer(tapGestureRecognizer)

        } else {
            self.view.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    // Update SettingsMenu
    func updateSettings() {
        let defaults = UserDefaults.standard
        
        toggleAmbientLightEstimation(defaults.bool(for: .ambientLightEstimation))
        showDebugVisuals = defaults.bool(for: .debugMode)
        detectedPlanesVisuals = defaults.bool(for: .detectedPlanesVisible)
        panGestureEnable = defaults.bool(for: .moveWithPanGesture)
        print("updateSettings reached")
        
        }
    }

// MARK: - VirtualObjectSelectionViewControllerDelegate
extension ViewController: VirtualObjectSelectionViewControllerDelegate {
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, object: String) {
        //loadVirtualObject(object: object)
        VirtualObjectName = object
        sessionInfoLabel.text = "当前选择模型为：\(translateIntoZh(text: VirtualObjectName))"
        debugPrint(self)
    }
}

// MARK: - Custom Debug String Convertible
extension ViewController {
    override var debugDescription: String {
        var selectedVirtualObjectInformation: String
        selectedVirtualObjectInformation = "Currently selected object is: " + "\(VirtualObjectName)"
        return selectedVirtualObjectInformation
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ViewController {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        updateSettings()
    }
}
