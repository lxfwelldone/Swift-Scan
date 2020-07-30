//
//  ViewController.swift
//  LzScan
//
//  Created by lg on 2020/4/23.
//  Copyright © 2020 lxf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {


    lazy var backView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.backgroundColor = .brown
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.backView)

        let btn: UIButton = UIButton.init(type: .contactAdd)
        btn.frame = CGRect(x: 30, y: 120, width: 60, height: 40)
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(toScan), for: .touchUpInside)
        

    }
    
    @objc func toScan() {
        let vc = LzScanSimpleVC()
        vc.modalPresentationStyle = .fullScreen
        vc.scanResultBlock = { (result: String) -> Void in
            debugPrint("扫描结果>>>>>>>\(result)")
            
        }
        present(vc, animated: true) {
//            block 在viewWillAppear 后执行
            debugPrint("present.......")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }

}

