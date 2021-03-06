//
//  CreateCompanyViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/15.
//

import UIKit

class CreateCompanyViewController: BaseViewController {
    private lazy var locations = [Location]()


    private lazy var saveButton = DoneButton(frame: CGRect(x: 0, y: 0, width: 50, height: 25)).then {
        $0.setTitle("保存".localizedString, for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.createArea()
        }
        
    }
    
    
    private lazy var header = AddAreaHeader(type: .company).then {
        $0.textField.delegate = self
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.bounces = false
        $0.register(AddAreaLocationCell.self, forCellReuseIdentifier: AddAreaLocationCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
    }
    
    private lazy var bottomAddAreaButton = ImageTitleButton(frame: .zero, icon: .assets(.plus_blue), title: "添加部门".localizedString, titleColor: .custom(.blue_2da3f6), backgroundColor: UIColor.custom(.white_ffffff))

    private var addAreaAlertView: InputAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        getDefaultAreas()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "添加公司".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.isEnabled = header.textField.text != ""
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.gray_f6f8fd)
        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(bottomAddAreaButton)
        
        bottomAddAreaButton.clickCallBack = { [weak self] in
            guard let self = self else { return }
            let addAreaAlertView = InputAlertView(labelText: "部门名称".localizedString, placeHolder: "请输入部门名称".localizedString) { [weak self] text in
                guard let self = self else { return }
                let area = Location()
                area.name = text
                if self.locations.map(\.name).contains(area.name) {
                    let text = getCurrentLanguage() == .chinese ? "\(area.name)已存在" : "\(area.name) already existed"
                    self.showToast(string: text)
                    
                } else {
                    self.locations.append(area)
                    self.tableView.reloadData()
                    self.addAreaAlertView?.removeFromSuperview()
                }
                
            }
            
            self.addAreaAlertView = addAreaAlertView
            
            SceneDelegate.shared.window?.addSubview(addAreaAlertView)
        }
    }
    
    override func setupConstraints() {
        header.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
            $0.height.equalTo(120)
        }
        
        bottomAddAreaButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(header.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomAddAreaButton.snp.top).offset(-18.5)
        }
    }
    
}

extension CreateCompanyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddAreaLocationCell.reusableIdentifier, for: indexPath) as! AddAreaLocationCell
        cell.location = locations[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        locations[indexPath.row].chosen = !locations[indexPath.row].chosen
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension CreateCompanyViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        if let point = touches.first?.location(in: tableView),
           tableView.point(inside: point, with: event) {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > 30 {
            textField.text = String(text.prefix(30))
        }
        
        
        
        if textField.text?.replacingOccurrences(of: " ", with: "").count == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = (text.count > 0)
        }
        
    }
}

extension CreateCompanyViewController {
    

    func getDefaultAreas() {
        let area0 = Location()
        area0.name = "总经办".localizedString
        let area1 = Location()
        area1.name = "行政部".localizedString
        let area2 = Location()
        area2.name = "市场部".localizedString
        let area3 = Location()
        area3.name = "研发部".localizedString
        let area4 = Location()
        area4.name = "财务部".localizedString
        let area5 = Location()
        area5.chosen = false
        area5.name = "销售部".localizedString
        let area6 = Location()
        area6.chosen = false
        area6.name = "法务部".localizedString
        let area7 = Location()
        area7.chosen = false
        area7.name = "采购部".localizedString
        let area8 = Location()
        area8.chosen = false
        area8.name = "会议室".localizedString

        locations = [area0, area1, area2, area3, area4, area5, area6, area7, area8]
        tableView.reloadData()
    }
    
    
    

}


extension CreateCompanyViewController {
    private func createArea() {
        if UserManager.shared.isLogin {
            createAreaInCloud()
        } else {
            createAreaInDB()
        }
    }
    
    private func createAreaInCloud() {
        guard let name = header.textField.text else { return }
        
        let areasArray = locations
            .filter { $0.chosen }
            .map(\.name)
        
        if areasArray.count == 0 {
            showToast(string: "请添加至少一个部门".localizedString)
            return
        }

        
        saveButton.isEnabled = false
        showLoadingView()
        ApiServiceManager.shared.createArea(name: name, location_names: [], department_names: areasArray, area_type: .company) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: "添加成功".localizedString)
            self.navigationController?.popViewController(animated: true)
            
        } failureCallback: { [weak self] code, err in
            self?.hideLoadingView()
            self?.saveButton.isEnabled = true
            self?.showToast(string: err)
        }

        
    }

    private func createAreaInDB() {
        guard let name = header.textField.text else { return }
        
        let areasArray = locations
            .filter { $0.chosen }
            .map(\.name)
        
        if areasArray.count == 0 {
            showToast(string: "请添加至少一个部门".localizedString)
            return
        }
        
        AreaCache.createArea(name: name, locations_name: areasArray, sa_token: "unbind\(UUID().uuidString)", mode: .company)
        showToast(string: "添加成功".localizedString)
        navigationController?.popViewController(animated: true)
        return
    }
}


// MARK: - RequestModels
extension CreateCompanyViewController {
    class DefaultLocationsResponse: BaseModel {
        var locations = [Location]()
    }
}
