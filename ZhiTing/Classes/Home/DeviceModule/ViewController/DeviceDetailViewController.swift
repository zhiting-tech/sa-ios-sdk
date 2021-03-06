//
//  DeviceDetailViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/18.
//

import UIKit

class DeviceDetailViewController: BaseViewController {
    lazy var device_id: Int = -1
    var area = Area()
    
    private var device: Device? {
        didSet {
            guard let device = device else { return }
            header.icon.setImage(urlString: device.logo_url, placeHolder: .assets(.default_device))
            header.deviceTypeLabel.text = device.name
            nameCell.valueLabel.text = device.name
            
            if area.areaType == .family {
                if let name = device.location?.name {
                    locationCell.valueLabel.text = name + " "
                } else {
                    locationCell.valueLabel.text = " "
                }
            } else {
                if let name = device.department?.name {
                   locationCell.valueLabel.text = name + " "
               } else {
                   locationCell.valueLabel.text = " "
               }
            }
            
            
            changeImgCell.valueLabel.text = (device.logo?.name ?? "") + " "

            cells.removeAll()
            if device.permissions.update_device {
                cells.append(nameCell)
                cells.append(locationCell)
                cells.append(changeImgCell)
            }
            
            deleteButton.isHidden = !device.permissions.delete_device
            
            tableView.reloadData()
        }
    }
    
    private lazy var cells = [ValueDetailCell]()

    private lazy var header = DeviceDetailHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 185))
    
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
        $0.tableHeaderView = header

    }
    
    private lazy var nameCell = ValueDetailCell().then {
        $0.title.text = "????????????".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var locationCell = ValueDetailCell().then {
        $0.title.text = "????????????".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var associatedPluginsCell = ValueDetailCell().then {
        $0.title.text = "????????????".localizedString
        $0.valueLabel.text = " "
    }
    
    private lazy var changeImgCell = ValueDetailCell().then {
        $0.title.text = "????????????".localizedString
        $0.valueLabel.text = " "
    }

    
    private lazy var deleteButton = ImageTitleButton(frame: .zero, icon: nil, title: "????????????".localizedString, titleColor: UIColor.custom(.black_333333), backgroundColor: UIColor.custom(.white_ffffff)).then {
        $0.clickCallBack = { [weak self] in
            self?.tipsAlert = TipsAlertView.show(message: "???????????????????".localizedString, sureCallback: { [weak self] in
                self?.deleteDevice()
            }, removeWithSure: false)
        }
        $0.isHidden = true
    }
    
    private var changeNameAlert: InputAlertView?
    
    private var tipsAlert: TipsAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = ""
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(tableView)
        view.addSubview(deleteButton)
        
        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
    }
    
    override func setupConstraints() {
        deleteButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(deleteButton.snp.top).offset(-10)
        }
    }
    
    override func setupSubscriptions() {
        websocket.disconnectDevicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] iid, success, error in
                guard let self = self else { return }
                if success {
                    self.tipsAlert?.removeFromSuperview()
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    self.showToast(string: error?.message ?? "????????????".localizedString)
                    self.tipsAlert?.isSureBtnLoading = false
                }   
            }
            .store(in: &cancellables)
    }
    
}

extension DeviceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if cells[indexPath.row].title.text == "????????????".localizedString {
            changeNameAlert = InputAlertView(labelText: "????????????".localizedString, placeHolder: "?????????????????????".localizedString, saveCallback: { [weak self] (text) in
                guard let self = self else { return }
                self.changeDeviceName(name: text)
            })
            if nameCell.valueLabel.text != " " {
                changeNameAlert?.textField.text = nameCell.valueLabel.text
            }
            SceneDelegate.shared.window?.addSubview(changeNameAlert!)
        } else if cells[indexPath.row].title.text == "????????????".localizedString {
            let vc = DeviceSetLocationViewController()
            vc.device = device
            vc.area = area
            navigationController?.pushViewController(vc, animated: true)
        } else if cells[indexPath.row].title.text == "????????????".localizedString {
            let vc = DeviceLogoViewController()
            vc.area = area
            vc.device = device
            navigationController?.pushViewController(vc, animated: true)
        }


    }
    
}

extension DeviceDetailViewController {
    @objc private func requestNetwork() {
        if device_id == -1 {
            tableView.mj_header?.endRefreshing()
            return
        }

        showLoadingView()
        ApiServiceManager.shared.deviceDetail(area: area, device_id: device_id) { [weak self] (response) in
            guard let self = self else { return }
            self.hideLoadingView()
            self.tableView.mj_header?.endRefreshing()
            self.device = response.device_info

            if response.device_info.model.hasPrefix("MH-SA") {
                self.deleteButton.isHidden = true
            }
        } failureCallback: { [weak self] (statusCode, errMessage) in
            self?.tableView.mj_header?.endRefreshing()
            self?.hideLoadingView()
            self?.showToast(string: errMessage)
        }

    }

    private func deleteDevice() {
        if device_id == -1 {
            showToast(string: "error")
            return
        }
        
        guard let device = device else {
            showToast(string: "error")
            return
        }
        
        tipsAlert?.isSureBtnLoading = true

        websocket.executeOperation(operation: .disconnectDevice(domain: device.plugin?.id ?? "", iid: device.iid))

    }
    
    private func changeDeviceName(name: String) {
        if device_id == -1 {
            showToast(string: "error")
            return
        }
        
        changeNameAlert?.saveButton.selectedChangeView(isLoading: true)
        ApiServiceManager.shared.editDevice(area: area, device_id: device_id, name: name, location_id: device?.location?.id ?? 0) { [weak self] _ in
            guard let self = self else { return }
            self.changeNameAlert?.saveButton.selectedChangeView(isLoading: false)
            self.requestNetwork()
            self.changeNameAlert?.removeFromSuperview()
            self.showToast(string: "????????????".localizedString)
        } failureCallback: { [weak self] (code, err) in
            self?.showToast(string: err)
            self?.changeNameAlert?.saveButton.selectedChangeView(isLoading: false)
        }
    }
    
    
}

