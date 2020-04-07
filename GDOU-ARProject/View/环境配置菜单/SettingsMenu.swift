//
//  ActionsMenu.swift
//  AREducationApp
//
//  Created by 刘友 on 2018/4/15.
//  Copyright © 2018年 刘友. All rights reserved.
//

import Foundation
import UIKit

enum Setting: String {
    
    case ambientLightEstimation
    case debugMode
    case detectedPlanesVisible

    case dragOnInfinitePlanes
    case scaleWithPinchGesture
    case moveWithPanGesture
    case rotateWithRotateGesture
    
    // Default Settings -
    // 1.ambientLightEstimation 2.dragOnInfinitePlanes
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.ambientLightEstimation.rawValue: true,
            Setting.dragOnInfinitePlanes.rawValue:true])
    }
}

extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    func integer(for setting: Setting) -> Int {
        return integer(forKey: setting.rawValue)
    }
    func set(_ integer: Int, for setting: Setting) {
        set(integer, forKey: setting.rawValue)
    }
}

class SettingsMenu: UITableViewController {
    
    //VISUALIZATION
    @IBOutlet weak var ambientLightEstimateSwitch: UISwitch!
    @IBOutlet weak var debugModeSwitch: UISwitch!
    @IBOutlet weak var detectedPlanesVisibleSwitch: UISwitch!
    //BEHAVIOR
    @IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
    @IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
    @IBOutlet weak var moveWithPanGestureSwitch: UISwitch!
    @IBOutlet weak var rotateWithRotateGestureSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSettings()
    }
    
    @IBAction func didChangeSetting(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
        case ambientLightEstimateSwitch:
            defaults.set(sender.isOn, for: .ambientLightEstimation)
        case debugModeSwitch:
            defaults.set(sender.isOn, for: .debugMode)
        case detectedPlanesVisibleSwitch:
            defaults.set(sender.isOn, for: .detectedPlanesVisible)
        case dragOnInfinitePlanesSwitch:
            defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
        case scaleWithPinchGestureSwitch:
            defaults.set(sender.isOn, for: .scaleWithPinchGesture)
        case moveWithPanGestureSwitch:
            defaults.set(sender.isOn, for: .moveWithPanGesture)
        case rotateWithRotateGestureSwitch:
            defaults.set(sender.isOn, for: .rotateWithRotateGesture)
        default: break
        }
    }
    
    private func populateSettings() {
        let defaults = UserDefaults.standard

        ambientLightEstimateSwitch.isOn = defaults.bool(for: .ambientLightEstimation)
        debugModeSwitch.isOn = defaults.bool(for: .debugMode)
        detectedPlanesVisibleSwitch.isOn = defaults.bool(for: .detectedPlanesVisible)
        dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
        moveWithPanGestureSwitch.isOn = defaults.bool(for: .moveWithPanGesture)
        rotateWithRotateGestureSwitch.isOn = defaults.bool(for: .rotateWithRotateGesture)
    }
    
    func dismissSettings() {
        ViewController().updateSettings()
        self.dismiss(animated: true, completion: nil)
    }

}
