//
//  MineViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/3.
//

import UIKit
import RealmSwift

class MineViewController: BaseViewController {
    private lazy var header = MineHeaderView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: ZTScaleValue(100) + Screen.statusBarHeight))

    private lazy var loginSectionHeader = MineLoginSectionHeader()
    
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.estimatedSectionHeaderHeight = 0
        $0.estimatedSectionFooterHeight = 0
        $0.separatorStyle = .none
        $0.tableHeaderView = header
        if #available(iOS 15.0, *) {
            $0.sectionHeaderTopPadding = 0
        }

        $0.register(MineViewCell.self, forCellReuseIdentifier: MineViewCell.reusableIdentifier)
        $0.alwaysBounceVertical = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        disableSideSliding = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
        requestNetwork()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)
        view.addSubview(tableView)
        
        header.infoCallback = { [weak self] in
            let vc = MineInfoViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        header.scanBtn.clickCallBack = { [weak self] _ in
            let vc = ScanQRCodeViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        loginSectionHeader.button.clickCallBack = { [weak self] _ in
            AuthManager.checkLoginWhenComplete(loginComplete: { [weak self] in
                self?.tableView.reloadData()
                self?.requestNetwork()
            }, jumpAfterLogin: true)
        }

    }
    
    override func setupSubscriptions() {
        authManager.roleRefreshPublisher
            .sink {  [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Screen.statusBarHeight)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

extension MineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if authManager.isLogin {
            let view = UIView()
            view.backgroundColor = .custom(.gray_f6f8fd)
            return view
        } else {
            return loginSectionHeader
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if authManager.isLogin {
            return 10
        } else {
            return ZTScaleValue(70)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineViewCell.reusableIdentifier, for: indexPath) as! MineViewCell
        switch indexPath.row {
        case 0:
            cell.title.text = "家庭/公司".localizedString
            cell.icon.image = .assets(.icon_family_brand)
        case 1:
            cell.title.text = "支持品牌".localizedString
            cell.icon.image = .assets(.icon_brand)
        case 2:
            if !authManager.isSAEnviroment {
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1
            }
            cell.title.text = "第三方平台".localizedString
            cell.icon.image = .assets(.icon_thirdParty)
        case 3:
            if !authManager.isSAEnviroment {
                cell.isUserInteractionEnabled = false
                cell.contentView.alpha = 0.5
            } else {
                cell.isUserInteractionEnabled = true
                cell.contentView.alpha = 1
            }
            cell.title.text = "专业版".localizedString
            cell.icon.image = .assets(.icon_professional)
        case 4:
            cell.title.text = "关于我们".localizedString
            cell.icon.image = .assets(.icon_about_us)
        default:
            break
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let vc = AreaListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = BrandListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = WKWebViewController(link: "https://sc.zhitingtech.com/#/third-platform")
            vc.webViewTitle = "第三方平台".localizedString
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = ProEditionViewController(link: "\(authManager.currentArea.sa_lan_address ?? "http://unkown")")
            let nav = BaseProNavigationViewController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case 4:
            let vc = AboutUsViewController()
//            let vc = WKWebViewController(link: "http://192.168.22.91/doc/js-sdk-base/js-sdk%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.html")
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }

    }
    
    func requestNetwork() {
        if authManager.isSAEnviroment || authManager.currentArea.sa_user_token.contains("unbind") {
            header.scanBtn.isHidden = false
        } else {
            header.scanBtn.isHidden = true
        }
        
        /// 如果是云端环境则用云端user_id 否则用对应SA的user_id 请求
        let user_id = authManager.isLogin ? authManager.currentUser.user_id : authManager.currentArea.sa_user_id
        
        if !authManager.isLogin && authManager.currentArea.id == nil {
            self.header.avatar.setImage(urlString: self.authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
            self.header.nickNameLabel.text = self.authManager.currentUser.nickname
            self.tableView.reloadData()
            return
        }

        /// 如果是云端的话 更新本地存储的用户信息
        if self.authManager.isLogin { // 云端用户信息
            ApiServiceManager.shared.cloudUserDetail(id: user_id) { [weak self] (response) in
                guard let self = self else { return }
                /// 如果是云端的话 更新本地存储的用户信息
                self.header.avatar.setImage(urlString: response.user_info.icon_url, placeHolder: .assets(.default_avatar))
                self.header.nickNameLabel.text = response.user_info.nickname
                self.authManager.currentUser = response.user_info
                UserCache.update(from: response.user_info)
                self.tableView.reloadData()

            } failureCallback: { [weak self] (code, err) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: self.authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
                self.header.nickNameLabel.text = self.authManager.currentUser.nickname
                self.tableView.reloadData()
            }
        } else { // sa用户信息
            ApiServiceManager.shared.userDetail(area: authManager.currentArea, id: user_id) { [weak self] (response) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: self.authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
                self.header.nickNameLabel.text = self.authManager.currentUser.nickname
                self.tableView.reloadData()

            } failureCallback: { [weak self] (code, err) in
                guard let self = self else { return }
                self.header.avatar.setImage(urlString: self.authManager.currentUser.icon_url, placeHolder: .assets(.default_avatar))
                self.header.nickNameLabel.text = self.authManager.currentUser.nickname
                self.tableView.reloadData()
            }
        }

    }
    
    
}


