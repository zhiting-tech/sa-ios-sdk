//
//  Area.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/17.
//

import Foundation

class Area: BaseModel {
    /// Area's id
    var id: String?
    
    /// Area's name
    var name = ""
    
    /// isbind smartAssistant
    var is_bind_sa: Bool = false
    
    /// smartAssistant's user_id
    var sa_user_id = 1
    
    /// smartAssistant's token  "unbind-xxx"说明是本地创建未绑定SA的家庭 ，""说明是云端创建的未绑定SA的家庭
    var sa_user_token = ""
    
    /// sa的wifi名称
    var ssid: String?
    
    /// sa的地址
    var sa_lan_address: String?
    
    /// sa的mac地址
    var bssid: String?
    
    /// 是否已经设置sa专业版账号
    var setAccount: Bool?
    
    /// sa专业版账号名
    var accountName: String?
    
    /// 云端用户的user_id
    var cloud_user_id = -1
    
    /// 是否需要重新将SA绑定云端
    var needRebindCloud = false
    
    /// 是否允许找回凭证
    var isAllowedGetToken = true
    

    func toAreaCache() -> AreaCache {
        let cache = AreaCache()
        cache.id = id
        cache.name = name
        cache.sa_user_token = sa_user_token
        cache.sa_user_id = sa_user_id
        cache.is_bind_sa = is_bind_sa
        cache.ssid = ssid
        cache.sa_lan_address = sa_lan_address
        cache.bssid = bssid
        cache.cloud_user_id = cloud_user_id
        cache.needRebindCloud = needRebindCloud
        if let is_set_password = setAccount {
            cache.setAccount = is_set_password
        }
        
    
        return cache
    }
    
    /// 临时通道地址
    var temporaryIP = "\(cloudUrl)/api"
    
    /// 请求的地址url(判断请求sa还是sc)
    var requestURL: URL {
        if bssid == NetworkStateManager.shared.getWifiBSSID() && bssid != nil {//局域网
            return URL(string: "\(sa_lan_address ?? "")/api")!
        } else if AuthManager.shared.isLogin && id != nil {
            return URL(string: temporaryIP)!
        } else {
            return URL(string: "\(sa_lan_address ?? "http://")")!
        }
    }

    

}

extension Area: CustomStringConvertible {
    var description: String {
        return self.toJSONString(prettyPrint: true) ?? ""
    } 
    
    
}


/// Use for syncing area to Smart Assistant
class SyncSAModel: BaseModel {
    var nickname = ""
    var area = AreaSyncModel()
    
    class LocationSyncModel: BaseModel {
        var name = ""
        var sort = 1
    }
    
    class AreaSyncModel: BaseModel {
        var name = ""
        var locations = [LocationSyncModel]()
    }
}
