//
//  VirtualObjectSelectionViewController.swift
//  AREducationApp
//
//  Created by 刘友 on 2018/5/26.
//  Copyright © 2018年 刘友. All rights reserved.
//

import UIKit

class VirtualObjectSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var size: CGSize!
    static let COUNT_OBJECTS = 12
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.frame = CGRect(origin: CGPoint.zero, size: self.size)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.bounces = false
        tableView.isScrollEnabled = true
        
        self.preferredContentSize = self.size
        self.view.addSubview(tableView)
        
    }

    // MARK: - UITableViewDelegate
    // Tells the delegate that the specified row is now selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.virtualObjectSelectionViewController(self, object: getObject(index: indexPath.row))
        self.dismiss(animated: true, completion: nil)
        print(getObject(index: indexPath.row))
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VirtualObjectSelectionViewController.COUNT_OBJECTS
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRect(x: 23, y: 10, width: 200, height: 30))
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = cell.contentView.frame
        cell.contentView.insertSubview(vibrancyView, at: 0)
        vibrancyView.contentView.addSubview(label)
        // Fill up the cell with data from the object.
        let object = getObject(index: indexPath.row)
        let labelText = translateIntoZh(text: object)
        label.text = labelText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
}


func getObject(index: Int) -> String {
    switch index {
    case 0:
        return "ant"
    case 1:
        return "cat"
    case 2:
        return "dog"
    case 3:
        return "duck"
    case 4:
        return "fish"
    case 5:
        return "mouse"
    case 6:
        return "flower1"
    case 7:
        return "flower2"
    case 8:
        return "stone"
    case 9:
        return "tree"
    case 10:
        return "house"
    case 11:
        return "confucius"
    default:
        return "default"
    }
}

func translateIntoZh(text: String) -> String{
    switch text {
    case "ant":
        return "蚂蚁"
    case "cat":
        return "猫咪"
    case "dog":
        return "狗狗"
    case "duck":
        return "鸭子"
    case "fish":
        return "小鱼儿"
    case "mouse":
        return "小老鼠"
    case "flower1":
        return "花朵1"
    case "flower2":
        return "花朵2"
    case "stone":
        return "石头"
    case "tree":
        return "树"
    case "house":
        return "屋子"
    case "confucius":
        return "孔子"
    default:
        return "default"
    }
}

// MARK: - VirtualObjectSelectionViewControllerDelegate
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, object: String)
}
