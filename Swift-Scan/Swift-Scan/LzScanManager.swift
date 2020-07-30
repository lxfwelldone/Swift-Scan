//
//  LzScanManager.swift
//  LzScan
//
//  Created by lg on 2020/4/23.
//  Copyright © 2020 lxf. All rights reserved.
//

import UIKit
import AVFoundation

enum LzScanMode {
    case once
    case always
}

class LzScanManager : NSObject{
    
    var hasHandleResult :Bool = false
    var hasInit :Bool = false
    let mode: LzScanMode = .once
    var delegate: LzScanProtocol? = nil
    
    lazy var session: AVCaptureSession = {
        let s = AVCaptureSession()
//        var preset: AVCaptureSession.Preset = AVCaptureSession.Preset.vga640x480
//        if s.canSetSessionPreset(.hd1280x720) {
//           preset = .hd1280x720
//            if s.canSetSessionPreset(.hd1920x1080) {
//                preset = .hd1920x1080
//                if s.canSetSessionPreset(.hd4K3840x2160) {
//                    preset = .hd4K3840x2160
//                }
//            }
//        }
//        s.sessionPreset = preset
        return s
    }()
    
    lazy var deviceInput: AVCaptureDeviceInput? = {

        let device: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            return input
        } catch  {
            return nil
        }
    }()
    
    // 拿到输出对象
    lazy var output: AVCaptureMetadataOutput = {
        let out = AVCaptureMetadataOutput()
        out.connection(with: .metadata)
        return out
    }()
    
    //预览大小
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer
    }()
    

    static let sharedInstance: LzScanManager = {
        let single = LzScanManager()
        return single
    }()
    

    func initParams(parentView: UIView, scanRect:CGRect) {
        
        if checkCameraAuth() {
             // 1.判断是否能够将输入添加到会话中  2.判断是否能够将输出添加到会话中
            if !session.canAddInput(deviceInput!) || !session.canAddOutput(output) {
                
                return
            }
            // 3.将输入和输出都添加到会话中
            session.addInput(deviceInput!)
            session.addOutput(output)
            // 4.设置输出能够解析的数据类型
            output.metadataObjectTypes =  output.availableMetadataObjectTypes
            //         output.metadataObjectTypes = [.ean13, .ean8, .upce, .code39, .code93, .code128, .code39Mod43, .qr];
            // 5.设置输出对象的代理, 只要解析成功就会通知代理
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //修改扫描位置
//            output.rectOfInterest = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: parentView.frame.size.height)

            
            // 添加预览图层,必须要插入到最下层的图层
            parentView.layer.insertSublayer(previewLayer, at: 0)
            previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            //预览就是正方形的了
//            parentView.clipsToBounds = true
            // 6.告诉session开始扫描
            
            
            let kScreenHeight: CGFloat = UIScreen.main.bounds.size.width
            let kScreenWidth: CGFloat = UIScreen.main.bounds.size.height
            
            let x:CGFloat = (kScreenHeight-scanRect.height)/(kScreenHeight*2)
            let y:CGFloat = (kScreenWidth-scanRect.width)/(kScreenWidth*2)

            //设置水平垂直居中扫描点
            let roi = CGRect(x:x, y: y, width: scanRect.height/kScreenHeight, height: scanRect.width/kScreenWidth)
            debugPrint(roi)
            output.rectOfInterest = roi
            hasInit = true
        }
    }
    
    func startRunning() {
        assert(hasInit, "请先设置预览父视图！才可以扫描哦")
        if !session.isRunning {
            session.startRunning()
            hasHandleResult = false
        }
    }
    func stopScan() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    
    /**是否具有相机权限
     */
    func checkCameraAuth() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized
    }
    

}

extension LzScanManager : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        debugPrint(">>>LzScanManager-----")

        for mObj in metadataObjects {

            guard let codeObj = mObj as? AVMetadataMachineReadableCodeObject else {
                return
            }
            debugPrint("-------扫码结果: \(codeObj.stringValue!)")

            if hasHandleResult {
                //处理结果后
                //
                guard let customDelegate = delegate else {
                    return
                }
                customDelegate.scanResult(result: codeObj.stringValue!)
            }
        }
    }
}
