//
//  LocalCache.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/30.
//

import Foundation
import RealmSwift




// MARK: - Cache Classes
class SmartAssistantCache: Object {
    @objc dynamic var ip_address: String = ""
    @objc dynamic var token: String = ""
    @objc dynamic var ssid = ""
    @objc dynamic var user_id = 1
    @objc dynamic var nickname = ""
    @objc dynamic var account_name = ""
    @objc dynamic var is_set_password = false
    @objc dynamic var phone = ""
    
    static func getSmartAssistantsFromCache() -> [SmartAssistant] {
        let realm = try! Realm()
        let sas = realm.objects(SmartAssistantCache.self)
        var array = [SmartAssistant]()
        sas.forEach {
            array.append($0.transformToSAModel())
        }

        return array
    }
    
    static func cacheSmartAssistants(sa: SmartAssistantCache) {
        let realm = try! Realm()
        
        if let cachedSa = realm.objects(SmartAssistantCache.self).filter("ip_address = '\(sa.ip_address)'").first {
            try? realm.write {
                let areas = realm.objects(AreaCache.self).filter("sa_token = '\(cachedSa.token)'")
                let locations = realm.objects(LocationCache.self).filter("sa_token = '\(cachedSa.token)'")
                let devices = realm.objects(DeviceCache.self).filter("sa_token = '\(cachedSa.token)'")
                
                areas.forEach {
                    $0.sa_token = sa.token
                }
                
                locations.forEach {
                    $0.sa_token = sa.token
                }
                
                devices.forEach {
                    $0.sa_token = sa.token
                }

                cachedSa.user_id = sa.user_id
                cachedSa.nickname = sa.nickname
                cachedSa.ssid = sa.ssid
                cachedSa.token = sa.token
                cachedSa.account_name = sa.account_name
                cachedSa.is_set_password = sa.is_set_password
                cachedSa.phone = sa.phone
                
            }
        } else {
            try? realm.write {
                realm.add(sa)
            }
        }
    }
    
    func transformToSAModel() -> SmartAssistant {
        let model = SmartAssistant()
        model.ip_address = ip_address
        model.is_set_password = is_set_password
        model.nickname = nickname
        model.phone = phone
        model.ssid = ssid
        model.token = token
        model.user_id = user_id
        model.account_name = account_name
        return model
    }
    
}




// MARK: - AreaCache
class AreaCache: Object {
    /// According SA's Token
    @objc dynamic var sa_token = ""
    
    /// area's id
    @objc dynamic var id: Int = 1
    /// area's name
    @objc dynamic var name = ""
    
    
    func increasePrimaryKey() {
        let realm = try! Realm()
        let currentMaxId = realm.objects(AreaCache.self).sorted(byKeyPath: "id", ascending: true).last?.id ?? 0
        id = currentMaxId + 1
    }
    
    func transferToArea() -> Area {
        let area = Area()
        area.id = id
        area.name = name
        area.sa_token = sa_token
        return area
    }
    
    
    static func cacheArea(areaCache: AreaCache) {
        let realm = try! Realm()
        try? realm.write {
            realm.add(areaCache)
        }
    }
    
    /// cache & update areas cache from api
    /// - Parameter areas: areas from api
    static func cacheAreas(areas: [Area]) {
        let realm = try! Realm()
        
        try? realm.write {
            if let token = areas.first?.sa_token {
                let caches = realm.objects(AreaCache.self).filter("sa_token = '\(token)'")
                realm.delete(caches)
            }
            
            areas.forEach {
                let cache = AreaCache()
                cache.name = $0.name
                cache.id = $0.id
                cache.sa_token = $0.sa_token
                realm.add(cache)
                
            }
        }
        
    }
    
    
    /// Create Area
    /// - Parameters:
    ///   - name: area's name
    ///   - areas_name: names of areas
    static func createArea(name: String, locations_name: [String], sa_token: String) {
        let area = AreaCache()
        area.increasePrimaryKey()
        area.sa_token = sa_token
        area.name = name
        
        let realm = try! Realm()
        try? realm.write {
            realm.add(area)
        }
        
        let locations = locations_name.map { name -> LocationCache in
            let location = LocationCache()
            location.sa_token = sa_token
            location.name = name
            location.area_id = area.id
            return location
        }
        
        try? realm.write {
            locations.forEach {
                $0.increasePrimaryKey()
                realm.add($0)
            }
        }

    }
    
    /// Delete a area from cache
    /// - Parameter area_id: area_id
    static func deleteArea(id: Int, sa_token: String) {
        let realm = try! Realm()
        if let area = realm.objects(AreaCache.self).filter("id = \(id) AND sa_token = '\(sa_token)'").first {
            let locations = realm.objects(LocationCache.self).filter("area_id = \(id) AND sa_token = '\(sa_token)'")
            let devices = realm.objects(DeviceCache.self).filter("area_id = \(id) AND sa_token = '\(sa_token)'")
            try? realm.write {
                realm.delete(area)
                realm.delete(locations)
                realm.delete(devices)
            }

        }
    }
    
    /// Change a area's name
    /// - Parameters:
    ///   - area_id: area_id
    ///   - name: new name
    static func changeAreaName(id: Int, name: String, sa_token: String) {
        let realm = try! Realm()
        if let area = realm.objects(AreaCache.self).filter("id = \(id) AND sa_token = '\(sa_token)'").first {
            try? realm.write {
                area.name = name
            }
        }
    }
    
    /// Area List
    /// - Returns: [Area]
    static func areaList() -> [Area] {
        let realm = try! Realm()
        var areaArray = [Area]()
        let result = realm.objects(AreaCache.self)
        result.forEach {
            areaArray.append($0.transferToArea())
        }
        
        return areaArray
    }
    
    /// Area Detail
    /// - Parameter id: area_id
    /// - Returns: (name: String, locations_count: Int)
    static func areaDetail(id: Int, sa_token: String) -> (name: String, locations_count: Int) {
        let realm = try! Realm()
        if let area = realm.objects(AreaCache.self).filter("id = \(id) AND sa_token = '\(sa_token)'").first {
            let locations_count = realm.objects(LocationCache.self).filter("area_id = \(id) AND sa_token = '\(sa_token)'").count
            return (area.name, locations_count)
        }
        
        return ("", 0)
    }
    
    
    /// 解除家庭绑定
    /// - Parameter sa_token: 要解除的家庭sa_token
    /// - Returns: 解除后的sa_token (unbind\(uuid))
    static func unbindArea(sa_token: String) -> String {
        let unbindToken = "unbind\(UUID().uuidString)"
        let realm = try! Realm()
        let area = realm.objects(AreaCache.self).filter("sa_token = '\(sa_token)'")
        let locations = realm.objects(LocationCache.self).filter("sa_token = '\(sa_token)'")
        let devices = realm.objects(DeviceCache.self).filter("sa_token = '\(sa_token)'")
        let sa = realm.objects(SmartAssistantCache.self).filter("token = '\(sa_token)'")
        try? realm.write {
            area.forEach {
                $0.sa_token = unbindToken
            }
            
            locations.forEach {
                $0.sa_token = unbindToken
            }
            
            realm.delete(sa)
            realm.delete(devices)
        }
        
        if let cacheSA = SmartAssistantCache.getSmartAssistantsFromCache().filter({ $0.token == "" }).first {
            AppDelegate.shared.appDependency.authManager.currentSA = cacheSA
        }
        
        return unbindToken
    }
    
}


// MARK: - LocationCache
class LocationCache: Object {
    /// According SA's Token
    @objc dynamic var sa_token = ""
    
    /// Area's id
    @objc dynamic var id: Int = 1
    
    /// Area's name
    @objc dynamic var name = ""
    
    /// involved area's id
    @objc dynamic var area_id = 0
    
    /// Area's order_index
    @objc dynamic var sort = 0
    
    
    func increasePrimaryKey() {
        let realm = try! Realm()
        let currentMaxId = realm.objects(LocationCache.self).sorted(byKeyPath: "id", ascending: true).last?.id ?? 0
        id = currentMaxId + 1
    }
    
    func transformToArea() -> Location {
        let area = Location()
        area.id = id
        area.name = name
        area.sa_token = sa_token
        area.area_id = area_id
        return area
    }
    
    static func cacheLocations(locations: [Location], token: String) {
        let realm = try! Realm()
        
        try? realm.write {
            let caches = realm.objects(LocationCache.self).filter("sa_token = '\(token)'")
            realm.delete(caches)
            
            
            locations.forEach { location in
                let cache = LocationCache()
                cache.area_id = location.area_id
                cache.name = location.name
                cache.id = location.id
                cache.sa_token = location.sa_token
                realm.add(cache)
            }
        }
        
    }

    /// Retrieve area's location
    /// - Parameter area_id: area's id
    /// - Returns: areas's locations
    static func areaLocationList(area_id: Int, sa_token: String) -> [Location] {
        let realm = try! Realm()
        var areasArray = [Location]()
        let result = realm.objects(LocationCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)'").sorted(byKeyPath: "sort")
        
        result.forEach {
            areasArray.append($0.transformToArea())
        }
        
        return areasArray
    }
    
    /// Retrieve the device
    /// - Parameter location_id: location_id
    /// - Returns: Area?
    static func locationDetail(location_id: Int, sa_token: String) -> Location? {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_token = '\(sa_token)'").first {
            return result.transformToArea()
        }
        return nil
    }
    
    /// AddLocationToArea
    /// - Parameters:
    ///   - area_id: id
    ///   - name: name
    static func addLocationToArea(area_id: Int, name: String, sa_token: String) {
        let realm = try! Realm()
        let location = LocationCache()
        location.name = name
        location.area_id = area_id
        location.sa_token = sa_token
        location.increasePrimaryKey()
        try? realm.write {
            realm.add(location)
        }
        
    }
    
    /// Change the location's name
    /// - Parameters:
    ///   - location_id: location's id
    ///   - name: new name
    static func changeAreaName(location_id: Int, name: String, sa_token: String) {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_token = '\(sa_token)'").first {
            try? realm.write {
                result.name = name
            }
        }
    }
    
    /// Delete the location
    /// - Parameter location_id: location_id
    static func deleteLocation(location_id: Int, sa_token: String) {
        let realm = try! Realm()
        if let result = realm.objects(LocationCache.self).filter("id = \(location_id) AND sa_token = '\(sa_token)'").first {
            let devices = realm.objects(DeviceCache.self).filter("location_id = \(location_id) AND sa_token = '\(sa_token)'")
            try? realm.write {
                realm.delete(result)
                realm.delete(devices)
            }
        }
    }
    
    static func setAreaOrder(area_id: Int, orderArray: [Int], sa_token: String) {
        let realm = try! Realm()
        
        
        for (idx, location_id) in orderArray.enumerated() {
            if let location = realm.objects(LocationCache.self).filter("area_id = \(area_id) AND id = \(location_id) AND sa_token = '\(sa_token)'").first {
                try! realm.write {
                    location.sort = idx
                }
            }
        }

    }
    
}


// MARK: - DeviceCache
class DeviceCache: Object {
    /// According SA's Token
    @objc dynamic var sa_token = ""
    /// device's id
    @objc dynamic var id: Int = -1
    /// device's name
    @objc dynamic var name = ""
    /// device's type
    @objc dynamic var model = ""
    /// device's brand id
    @objc dynamic var brand_id = ""
    /// device's logo
    @objc dynamic var logo_url = ""
    
    @objc dynamic var identity = ""
    
    @objc dynamic var plugin_id = ""
    
    @objc dynamic var area_id = 0
    
    @objc dynamic var location_id = 0
    
    @objc dynamic var is_sa = false
    
    func transformToDevice() -> Device {
        let device = Device()
        device.id = id
        device.name = name
        device.model = model
        device.brand_id = brand_id
        device.location_id = location_id
        device.area_id = area_id
        device.plugin_id = plugin_id
        device.identity = identity
        device.logo_url = logo_url
        device.sa_token = sa_token
        device.is_sa = is_sa
        return device
    }
    
    /// Retrieve devices by area_id
    /// - Parameter area_id: area_id
    /// - Returns: [Device]
    static func areaDeviceList(area_id: Int, sa_token: String) -> [Device] {
        let realm = try! Realm()
        var deviceArray = [Device]()
        let result = realm.objects(DeviceCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)'")
        result.forEach {
            deviceArray.append($0.transformToDevice())
        }
        return deviceArray

    }
    
    /// Retrieve devices by location_id
    /// - Parameter location_id: location_id
    /// - Returns: [Device]
    static func locationDeviceList(location_id: Int, sa_token: String) -> [Device] {
        let realm = try! Realm()
        var deviceArray = [Device]()
        let result = realm.objects(DeviceCache.self).filter("location_id = \(location_id) AND sa_token = '\(sa_token)'")
        result.forEach {
            deviceArray.append($0.transformToDevice())
        }
        return deviceArray
    }
    
    
    
    /// Cache devices
    /// - Parameter homeDevices: [Device]
    /// - Parameter sa_token: String
    static func cacheHomeDevices(homeDevices: [Device], area_id: Int, sa_token: String) {
        let realm = try! Realm()
        let deviceCaches = homeDevices.map { homeDevice -> DeviceCache in
            let device = DeviceCache()
            device.id = homeDevice.id
            device.name = homeDevice.name
            device.logo_url = homeDevice.logo_url
            device.plugin_id = homeDevice.plugin_id
            device.location_id = homeDevice.location_id
            device.area_id = homeDevice.area_id
            device.is_sa = homeDevice.is_sa
            device.sa_token = sa_token
            
            return device
        }
        
        let caches = realm.objects(DeviceCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)'")
        
        try? realm.write {
            realm.delete(caches)
            realm.add(deviceCaches)
        }
        
    }
    
    /// Retrieve home devices in the specific area
    /// - Parameters:
    ///   - area_id: area_id
    ///   - sa_token: sa_token
    /// - Returns: [HomeDevice]
    static func getAreaHomeDevices(area_id: Int, sa_token: String) -> [Device] {
        let realm = try! Realm()
        var homeDevices = [Device]()
        
        let caches = realm.objects(DeviceCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)'")
        
        caches.forEach {
            let device = Device()
            device.id = $0.id
            device.name = $0.name
            device.logo_url = $0.logo_url
            device.plugin_id = $0.plugin_id
            device.location_id = $0.location_id
            device.area_id = $0.area_id
            device.is_sa = $0.is_sa
            homeDevices.append(device)
        }

        return homeDevices
    }
    
    /// Retrieve HomeDevices by location_id
    /// - Parameter location_id: device's location_id
    /// - Parameter sa_token: device's sa_token
    /// - Returns: [Device]
    static func getLocationHomeDevices(location_id: Int, sa_token: String) -> [Device] {
        let realm = try! Realm()
        var homeDevices = [Device]()
        
        let caches = realm.objects(DeviceCache.self).filter("location_id = \(location_id) AND sa_token = '\(sa_token)'")
        
        caches.forEach {
            let device = Device()
            device.id = $0.id
            device.name = $0.name
            device.logo_url = $0.logo_url
            device.plugin_id = $0.plugin_id
            device.location_id = $0.location_id
            device.area_id = $0.area_id
            device.is_sa = $0.is_sa
            homeDevices.append(device)
        }

        return homeDevices
    }



}

class SceneCache: Object {
    @objc dynamic var area_id = 0
    /// According SA's Token
    @objc dynamic var sa_token = ""
    //场景ID
    @objc dynamic var id = 0
    //场景名称
    @objc dynamic var name = ""
    //修改场景状态权限
    @objc dynamic var control_permission = false
    //自动场景是否启动
    @objc dynamic var is_on = false
    //执行任务列表
//    @objc dynamic var items = [SceneItemModel]()
    //触发条件
//    @objc dynamic var condition = SceneConditionModel()
    //触发条件类型;1为定时任务, 2为设备
    @objc dynamic var type = 0
    //触发条件为设备时返回设备图片url
    @objc dynamic var logo_url = ""
    //设备状态:1正常2已删除3离线
    @objc dynamic var status = 0
    //是否自动
    @objc dynamic var is_auto = 0

    
    func transformToDevice() -> SceneTypeModel {
        let scene = SceneTypeModel()
        scene.id = id
        scene.name = name
        scene.control_permission = control_permission
        scene.is_on = is_on
        scene.condition.type = type
        scene.condition.logo_url = logo_url
        scene.condition.status = status
        scene.items = SceneItemCache.sceneItemsList(area_id: area_id, sa_token: sa_token, scene_id: id)
        return scene
    }
    
    /// Cache devices
    /// - Parameter SceneItems: [SceneItemModel]
    /// - Parameter sa_token: String
    static func cacheScenes(scenes: [SceneTypeModel], area_id: Int, sa_token: String,is_auto: Int) {
        let realm = try! Realm()
        let SceneCaches = scenes.map { scene -> SceneCache in
            let Scene_cache = SceneCache()
            Scene_cache.id = scene.id
            Scene_cache.name = scene.name
            Scene_cache.control_permission = scene.control_permission
            Scene_cache.is_on = scene.is_on
            Scene_cache.type = scene.condition.type
            Scene_cache.logo_url = scene.condition.logo_url
            Scene_cache.status = scene.condition.status
            Scene_cache.area_id = area_id
            Scene_cache.sa_token = sa_token
            Scene_cache.is_auto = is_auto
            //存储items
            SceneItemCache.cacheSceneItems(sceneItems: scene.items, area_id: area_id, sa_token: sa_token, scene_id: scene.id)
            return Scene_cache
        }
        
        let caches = realm.objects(SceneCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)' AND is_auto = \(is_auto)")
        try? realm.write {
            realm.delete(caches)
            realm.add(SceneCaches)
        }
    }

    
    /// Retrieve devices by area_id
    /// - Parameter area_id: area_id
    /// - Returns: [SceneItemModel]
    static func sceneList(area_id: Int, sa_token: String,is_auto: Int) -> [SceneTypeModel] {
        let realm = try! Realm()
        var sceneArray = [SceneTypeModel]()
        let result = realm.objects(SceneCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)' AND is_auto = \(is_auto)")
        result.forEach {
            sceneArray.append($0.transformToDevice())
        }
        return sceneArray
    }
    
}

class SceneItemCache: Object {
    /// According SA's Token
    @objc dynamic var sa_token = ""
    /// device's id
    @objc dynamic var area_id: Int = -1
    //执行任务类型;1为设备,2为场景
    @objc dynamic var type = 0
    //设备图片
    @objc dynamic var logo_url = ""
    //设备状态;1为正常,2为已删除,3为离线
    @objc dynamic var status = 0
    //是否自动类型
    @objc dynamic var scene_id = 0

    
    func transformToDevice() -> SceneItemModel {
        let device = SceneItemModel()
        device.type = type
        device.logo_url = logo_url
        device.status = status
        return device
    }
    
    /// Cache devices
    /// - Parameter SceneItems: [SceneItemModel]
    /// - Parameter sa_token: String
    static func cacheSceneItems(sceneItems: [SceneItemModel], area_id: Int, sa_token: String, scene_id: Int) {
        let realm = try! Realm()
        let itemCaches = sceneItems.map { sceneItem -> SceneItemCache in
            let itemCache = SceneItemCache()
            itemCache.type = sceneItem.type
            itemCache.status = sceneItem.status
            itemCache.logo_url = sceneItem.logo_url
            itemCache.area_id = area_id
            itemCache.sa_token = sa_token
            itemCache.scene_id = scene_id
            return itemCache
        }
        
        let caches = realm.objects(SceneItemCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)' AND scene_id = \(scene_id)")
        
        try? realm.write {
            realm.delete(caches)
            realm.add(itemCaches)
        }
        
    }

    
    /// Retrieve devices by area_id
    /// - Parameter area_id: area_id
    /// - Returns: [SceneItemModel]
    static func sceneItemsList(area_id: Int, sa_token: String, scene_id: Int) -> [SceneItemModel] {
        let realm = try! Realm()
        var itemArray = [SceneItemModel]()
        let result = realm.objects(SceneItemCache.self).filter("area_id = \(area_id) AND sa_token = '\(sa_token)' AND scene_id = \(scene_id)")
        result.forEach {
            itemArray.append($0.transformToDevice())
        }
        return itemArray
    }
}
