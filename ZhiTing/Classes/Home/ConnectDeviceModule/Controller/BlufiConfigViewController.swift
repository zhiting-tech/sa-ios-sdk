//
//  BlufiConfigViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/6/25.
//

import UIKit


class BlufiConfigViewController: BaseViewController {
    /// 设备
    var device = ESPPeripheral()
    
    /// blufi client
    var blufiClient: BlufiClient?
    
    /// 置网成功标识
    var successFlag = false
    
    private lazy var deviceImgView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.default_device)
    }
    
    private lazy var deviceNameLabel = Label().then {
        $0.text = ""
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
    }

    private lazy var wifiTextField = TitleTextField(title: "".localizedString, placeHolder: "请输入WIFI名".localizedString, isSecure: false, limitCount: 63).then {
        $0.textField.leftViewMode = .always
        
        let imageView = ImageView(frame: CGRect(x: 0, y: 11, width: 18, height: 18))
        imageView.image = .assets(.icon_wifi)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(imageView)
        
        $0.textField.leftView = leftView
    }
    
    private lazy var pwdTextField = TitleTextField(title: "".localizedString, placeHolder: "请输入wifi密码".localizedString, isSecure: true, limitCount: 63).then {
        $0.textField.leftViewMode = .always
        
        let imageView = ImageView(frame: CGRect(x: 0, y: 11, width: 18, height: 18))
        imageView.image = .assets(.icon_lock)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        leftView.clipsToBounds = true
        leftView.addSubview(imageView)
        

        
        $0.textField.leftView = leftView
    }
    
    private lazy var nextButton = LoadingButton(title: "下一步".localizedString)
    
    private lazy var connectView = ConnectView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "设备置网".localizedString

    }

    
    override func setupViews() {
        view.addSubview(deviceImgView)
        view.addSubview(deviceNameLabel)
        view.addSubview(wifiTextField)
        view.addSubview(pwdTextField)
        view.addSubview(nextButton)
        view.addSubview(connectView)

        
        nextButton.addTarget(self, action: #selector(setupDeviceWifi), for: .touchUpInside)
        
        connectView.reconnectCallback = { [weak self] in
            guard let self = self else { return }
            self.connect()
        }
        
        connectView.finishCallback = { [weak self] in
            guard let self = self else { return }
            self.connectView.removeFromSuperview()
        }

        
        connectView.startLoading()
        connect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.connectView.finishLoading()
        }

        wifiTextField.textField.text = networkStateManager.getWifiSSID()
    }

    override func setupConstraints() {
        deviceImgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(43))
            $0.width.height.equalTo(ZTScaleValue(105))
        }
        
        deviceNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deviceImgView.snp.bottom).offset(5)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        wifiTextField.snp.makeConstraints {
            $0.top.equalTo(deviceNameLabel.snp.bottom).offset(ZTScaleValue(55))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))

        }
        
        pwdTextField.snp.makeConstraints {
            $0.top.equalTo(wifiTextField.snp.bottom).offset(ZTScaleValue(10))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))

        }


        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10 - Screen.bottomSafeAreaHeight))
        }


    }
    


}

extension BlufiConfigViewController {
    /// 为设备配网
    @objc
    func setupDeviceWifi() {
        let ssid = wifiTextField.textField.text ?? ""
        let pwd = pwdTextField.text
        if ssid.count == 0 {
            showToast(string: "请先输入wifi名称".localizedString)
            return
        }
        
        if pwd.count == 0 {
            showToast(string: "请先输入密码".localizedString)
            return
        }

        nextButton.buttonState = .waiting
        
        
        
        let params = BlufiConfigureParams()

        params.opMode = OpModeSta
        params.staSsid = ssid
        params.staPassword = pwd
            

        
        blufiClient?.configure(params)

    }
    
    private func connect() {
        connectView.startLoading()
        blufiClient?.close()
        blufiClient = BlufiClient()
        blufiClient?.centralManagerDelete = self
        blufiClient?.peripheralDelegate = self
        blufiClient?.blufiDelegate = self
        blufiClient?.connect(device.uuid.uuidString)
    }
    
}

extension BlufiConfigViewController: CBCentralManagerDelegate, CBPeripheralDelegate, BlufiDelegate {
    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("连接成功")
        connectView.finishLoading()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败")
        connectView.failToConnect()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("连接断开")
        if !successFlag {
            showToast(string: "与设备连接断开".localizedString)
        }
        
        navigationController?.popViewController(animated: true)
    }


    // MARK: - BlufiDelegate
    
    func blufi(_ client: BlufiClient, gattPrepared status: BlufiStatusCode, service: CBService?, writeChar: CBCharacteristic?, notifyChar: CBCharacteristic?) {
        print("Blufi gattPrepared \(status)")
        if status == StatusSuccess { // success
            
        } else { // failed
           
        }

    }
    
    func blufi(_ client: BlufiClient, didNegotiateSecurity status: BlufiStatusCode) {
        print("Blufi didNegotiateSecurity \(status)")
        if status == StatusSuccess { // success
            
        } else { // failed
            
        }
    }
    
    func blufi(_ client: BlufiClient, didPostConfigureParams status: BlufiStatusCode) {
        print("Blufi didPostConfigureParams ")
    }
    
    func blufi(_ client: BlufiClient, didReceiveDeviceStatusResponse response: BlufiStatusResponse?, status: BlufiStatusCode) {
        print("Blufi didReceiveDeviceStatusResponse ")
        nextButton.buttonState = .normal
        if status == StatusSuccess {
            successFlag = true
            showToast(string: "置网成功".localizedString)
        } else {
            showToast(string: "置网失败".localizedString)
        }
    }
    
    
    func blufi(_ client: BlufiClient, didReceiveError errCode: Int) {
        print("Blufi didReceiveError \(errCode)")
        connectView.failToConnect()

    }
    
    
}

// MARK: - 连接过程view
extension BlufiConfigViewController {
    class ConnectView: UIView {
        private lazy var percentageView = ConnectPercentageView()
        
        private lazy var statusLabel = ConnectStatusLabel()
        
        var finishCallback: (() -> ())?
        
        var reconnectCallback: (() -> ())? {
            didSet {
                statusLabel.reconnectCallback = reconnectCallback
            }
        }
        
        private lazy var count: CGFloat = 0.0

        private var timer: Timer?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .custom(.white_ffffff)
            addSubview(percentageView)
            addSubview(statusLabel)
            
            percentageView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(75)
                $0.width.height.equalTo(Screen.screenWidth - 175)
            }
            
            statusLabel.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.top.equalTo(percentageView.snp.bottom).offset(20)
            }
        }
        
        func startLoading() {
            timer?.invalidate()
            percentageView.setProgress(progress: 0)
            statusLabel.status = .connecting
            timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                self.count += 0.01
                self.percentageView.setProgress(progress: self.count)
                if self.count >= 0.95 {
                    timer.invalidate()
                }
            })
            timer?.fire()
            RunLoop.main.add(timer!, forMode: .common)
        }
        
        func finishLoading() {
            timer?.invalidate()
            timer = Timer(timeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                self.count += 0.01
                self.percentageView.setProgress(progress: self.count)
                if self.count >= 1 {
                    timer.invalidate()
                    self.statusLabel.status = .success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                        self?.finishCallback?()

                    }
                    
                }
            })
            timer?.fire()
            RunLoop.main.add(timer!, forMode: .common)
        }
        
        func failToConnect(_ err: String = "") {
            timer?.invalidate()
            count = 0
            percentageView.setProgress(progress: 0)
            statusLabel.status = .fail
        }

    }
    
    
}


