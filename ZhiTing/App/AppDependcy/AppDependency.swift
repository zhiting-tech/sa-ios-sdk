//
//  AppDependcy.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/22.
//
import Moya
import Foundation
import IQKeyboardManagerSwift
import Kingfisher
import Toast_Swift
import Combine
import RealmSwift


struct AppDependency {
    let websocket: ZTWebSocket
    let apiService: MoyaProvider<ApiService>
    var tabbarController: TabbarController
    let openUrlHandler: OpenUrlHandler
    let networkManager: StateManager
    let authManager: AuthManager
    let currentAreaManager: CurrentAreaManager
    lazy var cancellables = [AnyCancellable]()
}

fileprivate let requestClosure = { (endpoint: Endpoint, closure: (Result<URLRequest, MoyaError>) -> Void)  -> Void in
    do {
        var  urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = 10
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.httpShouldHandleCookies = false
        closure(.success(urlRequest))
    } catch MoyaError.requestMapping(let url) {
        closure(.failure(MoyaError.requestMapping(url)))
    } catch MoyaError.parameterEncoding(let error) {
        closure(.failure(MoyaError.parameterEncoding(error)))
    } catch {
        closure(.failure(MoyaError.underlying(error, nil)))
    }
    
}


extension AppDependency {
    static func resolve() -> AppDependency {
        let websocket = ZTWebSocket()
        let apiService = MoyaProvider<ApiService>(requestClosure: requestClosure)
        let tabbarController = TabbarController()
        let openUrlHandler = OpenUrlHandler()
        let networkStatusListener = StateManager()
        let authManager = AuthManager()
        let currentAreaManager = CurrentAreaManager()

        return AppDependency(
            websocket: websocket,
            apiService: apiService,
            tabbarController: tabbarController,
            openUrlHandler: openUrlHandler,
            networkManager: networkStatusListener,
            authManager: authManager,
            currentAreaManager: currentAreaManager
        )
        
    }
    
    func config() {
        // keyboard config
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // kingfisher
        KingfisherManager.shared.downloader.downloadTimeout = 30
        
        // toast-swift
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = false
        ToastManager.shared.position = .center
        ToastManager.shared.duration = 1.5
        ToastManager.shared.style.titleFont = .font(size: 14, type: .medium)

        // url
//        baseUrl = "http://192.168.0.84:8088"
        cloudUrl = "http://192.168.0.159:8081/api"
        
        print("RealmPath: \(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")")
        
        // websocket
//        websocket.setUrl(urlString: "ws://192.168.0.84:8088/ws")
        
    }
    
    
}








