//
//  ApiResponseModel.swift
//  ZhiTing
//
//  Created by iMac on 2021/8/11.
//

import Foundation


// MARK: - ResposneModel
class PagerModel: BaseModel {
    /// 当前页数
    var page = 0
    /// 每页数量
    var page_size = 0
    /// 总条数
    var total_rows = 0
    /// 是否有更多
    var has_more = true
}

 class CaptchaResponse: BaseModel {
    var captcha_id = ""
}

 class RegisterResponse: BaseModel {
    var user_info = User()
}

 class AreaListReponse: BaseModel {
    var areas = [Area]()
}

class SceneListReponse: BaseModel {
    //手动场景列表
    var manual = [SceneTypeModel]()
    //自动场景列表
    var auto_run = [SceneTypeModel]()
    
}

class BindCloudResponse: BaseModel {
    /// 绑定云端时，用于客户端更新自己sc的area_id
    var area_id: Int64?
}

class AreaDetailResponse: BaseModel {
        var name = ""
        var location_count = 0
}

class AreaLocationListResponse: BaseModel {
    var locations = [Location]()
}

class CreateAreaResponse: BaseModel {
    var id = ""
    var cloud_sa_user_info: CreateAreaCloudSAInfo?
}

class CreateAreaCloudSAInfo: BaseModel {
    var id = 0
    var token = ""
}

class DeviceListResponseModel: BaseModel {
    var devices = [Device]()
}

class ScanResponse: BaseModel {
    var user_info = User()
    var area_info = areaInfo()
    
    class areaInfo: BaseModel {
        var id = ""
    }
}

class QRCodeResponse: BaseModel {
    var qr_code = ""
    
}

class ResponseModel: BaseModel {
    var device_id: Int = -1
    var user_info = User()
    var plugin_url = ""
    var area_info = areaInfo()
    
    class areaInfo: BaseModel {
        var id: String?
    }
}

class AddDeviceResponseModel: BaseModel {
    var device_id: Int = -1
    var user_info = User()
    var plugin_url = ""
    var area_info = AreaInfo()
    
    class AreaInfo: BaseModel {
        var id: String?
    }
}

class SABindResponse: BaseModel {
    var is_bind = false
}

class DeviceInfoResponse: BaseModel {
    var device_info = Device()
}

class ScopeTokenModel: BaseModel {
    var token = ""
    var expires_in = 0
}

class ScopeTokenResponse: BaseModel {
    var scope_token = ScopeTokenModel()
}

class InfoResponse: BaseModel {
    var user_info = User()
}

class BrandListResponseModel: BaseModel {
    var brands = [Brand]()
}

class BrandDetailResponse: BaseModel {
    var brand = Brand()
}

class RolePermissionsResponse: BaseModel {
    var permissions = RolePermission()
}

class MembersResponse: BaseModel {
    var self_id = 0
    var is_owner = false
    var users = [User]()
}

class RoleListResponse: BaseModel {
    var roles = [Role]()
}

class TemporaryResponse: BaseModel {
    //临时通道地址
    var host = ""
    
    //端口过期时间,单位秒
    var expires_time = 0
    
    //存储的时间
    var saveTime = ""
}

class SATokenResponse: BaseModel {
    var sa_token = ""
    
}

class DeviceAccessTokenResponse: BaseModel {
    var access_token = ""
    var expires_in = 0
}

///// common设备类型列表
//class CommonDeviceTypeListResponse: BaseModel {
//    var list = [CommonDeviceType]()
//    var pager = PagerModel()
//}
//
///// common设备列表
//class CommonDeviceListResponse: BaseModel {
//    var list = [CommonDeviceDetail]()
//    var pager = PagerModel()
//}


class CommonDeviceTypeListResponse: BaseModel {
    var types = [CommonDeviceListResponse]()
}

class CommonDeviceListResponse: BaseModel{
    var name = ""
    var type = "" //类型（light灯；siwthc开关；outlet插座；routing_gateway路由网关；sensor感应器；security安防）
    var devices = [CommonDevice]()//设备列表

}

class CommonDevice: BaseModel {
    var name = ""
    var model = "" //型号
    var manufacturer = "" //厂商
    var logo = "" //logo地址
    var provisioning = "" //内置网页地址
    var plugin_id = "" //插件id
}

class pluginResponse: BaseModel {
    var plugin = Plugin()
}

class captchaResponse: BaseModel{
    var status = 0
    var reason = ""
    var code = ""
    var expire_in = 0//有效时长，秒
}
