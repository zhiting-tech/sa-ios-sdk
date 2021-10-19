//
//  LaunchViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//

import UIKit
import RealmSwift

class LaunchViewController: BaseViewController {
    lazy var udpTool = UDPDeviceTool()

    lazy var image = ImageView().then {
        $0.image = .assets(.icon_launch)
    }
    
    lazy var label = Label().then {
        $0.text = "你的智能生活助手"
        $0.font = .font(size: 30, type: .light)
        $0.numberOfLines = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfExistAccordingLocalSA()
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(image)
        view.addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(27.5)
        }
        
        image.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16.5 - Screen.bottomSafeAreaHeight)
            $0.width.equalTo(70)
            $0.height.equalTo(65)
            $0.centerX.equalToSuperview()
        }
    }
}


extension LaunchViewController {
    

    func checkIfExistAccordingLocalSA() {
        let areas = AreaCache.areaList()
        let wifiSSID = networkStateManager.getWifiSSID()
        let wifiMac = networkStateManager.getWifiBSSID()
        
        print("wifi SSID: \(String(describing: wifiSSID))")
        print("wifi Mac:\(String(describing: wifiMac))")

        if let user = UserCache.getUsers().first {
            AuthManager.shared.currentUser = user
        } else {
            let user = User()
            user.nickname = "User_" + UUID().uuidString.prefix(6)
            UserCache.update(from: user)
            AuthManager.shared.currentUser = user
        }

        if let area = areas.first(where: { $0.ssid == wifiSSID && $0.bssid == wifiMac && $0.ssid != nil && $0.bssid != nil }) {
            AuthManager.shared.currentArea = area
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
            }
   
        } else {
            if areas.count == 0 {
                setupNewLocalSAandUser()
            }
            
            if let currentArea = AreaCache.areaList().first {
                AuthManager.shared.currentArea = currentArea
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    SceneDelegate.shared.window?.rootViewController = AppDelegate.shared.appDependency.tabbarController
                   
                }
            }
            
        }
    }
    
    
    func setupNewLocalSAandUser() {
        /// 用于触发本地网络权限弹窗
        try? udpTool.beginScan()
        
        let area = AreaCache.createArea(name: "我的家".localizedString, locations_name: [], sa_token: "unbind\(UUID().uuidString)")

        AuthManager.shared.currentArea = area.transferToArea()
        
        
    }
}

