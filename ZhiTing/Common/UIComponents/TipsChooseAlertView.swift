//
//  TipsChooseAlertView.swift
//  ZhiTing
//
//  Created by macbook on 2021/7/9.
//

import UIKit

class TipsChooseAlertView: UIView {

    var sureCallback: ((_ tap: Int) -> ())?
    var cancelCallback: (() -> ())?

    var removeWithSure = true
    
    var isSureBtnLoading = false {
        didSet {
            sureBtn.selectedChangeView(isLoading: isSureBtnLoading)
        }
    }
    private lazy var cover = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.3)
    }

    private lazy var container = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.clipsToBounds = true
    }

    private lazy var tipsLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .center
        $0.textColor = .custom(.black_3f4663)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private lazy var chooseButton = Button().then {
        $0.setImage(.assets(.unselected_tick), for: .normal)
        $0.setImage(.assets(.selected_tick_red), for: .selected)
        $0.addTarget(self, action: #selector(chooseButtonOnPress), for: .touchUpInside)
    }
    
    private lazy var chooseLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.textAlignment = .left
        $0.textColor = .custom(.red_fe0000)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(chooseButtonOnPress)))
    }
    
    @objc private func chooseButtonOnPress(){
        chooseButton.isSelected = !chooseButton.isSelected
    }
    
    private lazy var sureBtn = CustomButton(buttonType:
                                                .centerTitleAndLoading(normalModel:
                                                                        .init(
                                                                            title: "??????".localizedString,
                                                                            titleColor: .custom(.blue_2da3f6),
                                                                            font: .font(size: ZTScaleValue(14), type: .bold),
                                                                            backgroundColor: .custom(.white_ffffff)
                                                                        )
                                                )).then {
                                                    $0.layer.borderWidth = 0.5
                                                    $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
                                                    $0.addTarget(self, action: #selector(onClickSure), for: .touchUpInside)
                                                }
    
    private lazy var cancelBtn = Button().then {
        $0.setTitle("??????".localizedString, for: .normal)
        $0.setTitleColor(.custom(.gray_94a5be), for: .normal)
        $0.titleLabel?.font = .font(size: ZTScaleValue(14), type: .bold)
        $0.layer.borderWidth = ZTScaleValue(0.5)
        $0.layer.borderColor = UIColor.custom(.gray_eeeeee).cgColor
        $0.clickCallBack = { [weak self] _ in
            self?.cancelCallback?()
            self?.removeFromSuperview()
        }

        
    }

    @objc private func onClickSure() {
        sureCallback?(chooseButton.isSelected ? 1 : 0)//???????????????1??????????????????0
        if removeWithSure {
            removeFromSuperview()
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    convenience init(frame: CGRect, message: String) {
        self.init(frame: frame)
        self.tipsLabel.text = message
    }
    
    convenience init(frame: CGRect, attributedString: NSAttributedString,chooseString: String) {
        self.init(frame: frame)
        self.tipsLabel.attributedText = attributedString
        self.chooseLabel.text = chooseString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform.identity
        })
            
        
    }
    
    override func removeFromSuperview() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        },completion: { isFinished in
            if isFinished {
                super.removeFromSuperview()
            }
            
        })
        
    }
    
    private func setupViews() {
        addSubview(cover)
        addSubview(container)
        container.addSubview(tipsLabel)
        container.addSubview(chooseButton)
        container.addSubview(chooseLabel)
        container.addSubview(sureBtn)
        container.addSubview(cancelBtn)
        
    }

    private func setConstrains() {
        cover.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        container.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth - ZTScaleValue(75))
        }
        
        tipsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        chooseButton.snp.makeConstraints {
            $0.top.equalTo(tipsLabel.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalTo(ZTScaleValue(23.5))
            $0.width.height.equalTo(ZTScaleValue(18.5))
        }
        
        chooseLabel.snp.makeConstraints {
            $0.left.equalTo(chooseButton.snp.right).offset(ZTScaleValue(8.5))
            $0.top.equalTo(chooseButton)
            $0.right.equalTo(-ZTScaleValue(23.5))
        }
        
        sureBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.right.equalToSuperview()
            $0.top.equalTo(chooseLabel.snp.bottom).offset(ZTScaleValue(30))
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.height.equalTo(ZTScaleValue(50))
            $0.left.equalToSuperview()
            $0.top.equalTo(chooseLabel.snp.bottom).offset(ZTScaleValue(30))
            $0.width.equalTo((Screen.screenWidth - ZTScaleValue(75)) / 2)
            $0.bottom.equalToSuperview()
        }
    }
    
    @discardableResult
    static func show(message: String, sureCallback: ((_ tap: Int) -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TipsChooseAlertView {
        let tipsView = TipsChooseAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), message: message)
        tipsView.removeWithSure = removeWithSure
        tipsView.sureCallback = sureCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }
    
    @discardableResult
    static func show(attributedString: NSAttributedString, chooseString: String,sureCallback: ((_ tap: Int) -> ())?, cancelCallback: (() -> ())? = nil, removeWithSure: Bool = true) -> TipsChooseAlertView {
        let tipsView = TipsChooseAlertView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight), attributedString: attributedString, chooseString: chooseString)
        tipsView.removeWithSure = removeWithSure
        tipsView.sureCallback = sureCallback
        tipsView.cancelCallback = cancelCallback
        UIApplication.shared.windows.first?.addSubview(tipsView)
        return tipsView
    }

}
