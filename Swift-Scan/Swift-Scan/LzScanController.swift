//
//  LzScanController.swift
//  LzScan
//
//  Created by lg on 2020/5/4.
//  Copyright © 2020 lxf. All rights reserved.
//

import UIKit

class LzScanController: UIViewController {
        
    typealias ScanResultBlock = (String) -> ()
    var scanResultBlock: ScanResultBlock? = nil
    
    lazy var backView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.backgroundColor = .brown
        return v
    }()
    
    lazy var scanView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 255, height: 255))
        v.center = self.view.center
        v.backgroundColor = UIColor.clear
        v.layer.borderColor = UIColor.yellow.cgColor
        v.layer.borderWidth = 2
        return v
    }()
    
    lazy var scanLine: UIView = {
        let v = UIView(frame: CGRect(x: 15, y: 15, width: 255-30, height: 1))
        v.backgroundColor = UIColor.cyan
        return v
    }()
    var moveTimer: Timer?
    let moveDuration: TimeInterval = 2.5
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint(">>>>>>>>>>>>>>viewWillAppear")
        startTimer()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint(">>>>>>>>>>>>>>viewDidLoad")
        

        let rect:CGRect = CGRect(x: 0, y: 100, width: 255, height: 255)
//        内部默认设置为水平垂直居中
        LzScanManager.sharedInstance.initParams(parentView: self.view, scanRect: rect)
        LzScanManager.sharedInstance.startRunning()
        
        self.view.addSubview(self.scanView)
        self.scanView.addSubview(self.scanLine)
        self.view.addSubview(self.backView)

    }
    
    //  计时器方法
    @objc func timerAction(){

        scanLine.frame = CGRect(x: self.scanLine.frame.origin.x, y: 15, width: scanLine.frame.size.width, height: scanLine.frame.size.height)

        UIView.animate(withDuration: moveDuration) {
            self.scanLine.frame = CGRect(x: self.scanLine.frame.origin.x, y: self.scanView.frame.size.height - 15, width: self.scanLine.frame.size.width, height: self.scanLine.frame.size.height)
        }

    }
    

    /**
     开始计时器
     */
    func startTimer(){
        if moveTimer == nil {
            moveTimer = Timer(timeInterval: moveDuration, target: self, selector:#selector(timerAction), userInfo: nil, repeats: true);
            RunLoop.main.add(moveTimer!, forMode: RunLoop.Mode.common)
        }
        moveTimer!.fire()
    }
    
    /**
     移除计时器
     */
    func endTimer(){
        if moveTimer == nil {
            return
        }
        moveTimer!.invalidate()
        moveTimer = nil
    }
}
