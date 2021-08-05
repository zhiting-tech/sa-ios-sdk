//
//  StateManager.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/22.
//

import Foundation
import Alamofire
import Combine
import CoreLocation
import SystemConfiguration.CaptiveNetwork

// MARK: - StateManager
class NetworkStateManager: NSObject {
    enum NetworkStatus {
        case reachable
        case noNetwork
    }
    
    /// 当前Wifi SSID
    var currentWifiSSID: String?
    var currentWifiMAC: String?
    
    var locationManager: CLLocationManager?
    
    var networkState: NetworkStatus = .reachable
    
    private lazy var reachabilityManager = NetworkReachabilityManager()
    
    lazy var networkStatusPublisher = PassthroughSubject<NetworkStatus, Never>()

    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        reachabilityManager?.startListening(onUpdatePerforming: { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.networkState = .noNetwork
                self?.networkStatusPublisher.send(.noNetwork)
            case .reachable:
                self?.networkState = .reachable
                AppDelegate.shared.appDependency.websocket.connect()
                self?.networkStatusPublisher.send(.reachable)
            }
            
            AppDelegate.shared.appDependency.authManager.currentRolePermissions = RolePermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AppDelegate.shared.appDependency.authManager.getRolePermissions()
            }
            
            self?.currentWifiSSID = self?.getWifiSSID()
            self?.currentWifiMAC = self?.getWifiBSSID()
            self?.cacheCurrentWifi(ssid: self?.currentWifiSSID, bssid: self?.currentWifiMAC)
            print("当前wifi环境为: \(self?.currentWifiSSID ?? "nil")")
        })
    }
    
    

    
        
    

    
}

extension NetworkStateManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            currentWifiSSID = getWifiSSID()
        }
    }
}



extension NetworkStateManager {
    private func checkIPIsCurrentSA() {

    }

    /// get the wifi ssid
    /// - Returns: ssid: String?
    func getWifiSSID() -> String? {
      var ssid: String?

      if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
          if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
            ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
            break
          }
        }
      }
        
        
        
      #if targetEnvironment(simulator)
      currentWifiSSID = "simulator"
      return "simulator"
      #else
      currentWifiSSID = ssid
      return ssid
      #endif
    }
    
    
    func getWifiBSSID() -> String? {
        var BSSID: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
              if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                BSSID = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                break
              }
            }
        }
        
        #if targetEnvironment(simulator)
        currentWifiMAC = "simulator"
        return "simulator"
        #else
        currentWifiMAC = BSSID
        return BSSID
        #endif
    }
    
    private func getAddress(for network: NetworkENV) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        
        freeifaddrs(ifaddr)

        return address
    }



    private enum NetworkENV: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        case ipv4 = "ipv4"
        case ipv6 = "ipv6"
    }
    
    
    /// 缓存连接过的wifi
    func cacheCurrentWifi(ssid: String?, bssid: String?) {
        guard let ssid = ssid, let bssid = bssid else {
            return
        }
        
        var list = getHistoryWifiList()
        if let wifi = list.first(where: { $0.bssid == bssid }) {
            wifi.ssid = ssid
        } else {
            let model = WifiModel()
            model.ssid = ssid
            model.bssid = bssid
            list.append(model)
        }
        
        UserDefaults.standard.setValue(list.toJSONString(prettyPrint: true), forKey: "wifiHistoryList")
        UserDefaults.standard.synchronize()
    }
    
    /// 获取连接过的wifi列表
    func getHistoryWifiList() -> [WifiModel] {
        if let json = UserDefaults.standard.string(forKey: "wifiHistoryList"),
           let list = [WifiModel].deserialize(from: json)?.compactMap({ $0 }) {
            return list
        }
        
        return [WifiModel]()
    }

}


class WifiModel: BaseModel {
    var ssid = ""
    var bssid = ""
}