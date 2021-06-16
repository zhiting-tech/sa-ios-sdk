//
//  EditSceneSectionHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/12.
//

import UIKit

class EditSceneSectionHeader: UIView {
    enum HeaderType {
        case condition
        case action
    }
    
    lazy var type: HeaderType = .condition
    

    private lazy var roundedTop = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var titleLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(18), type: .bold)
        $0.textColor = .custom(.black_3f4663)
    }

    private lazy var detailLabel = Label().then {
        $0.font = .font(size: ZTScaleValue(11), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
    }
    
    lazy var plusButton = Button().then {
        $0.setImage(.assets(.plus_blue_circle), for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, type: HeaderType) {
        self.init(frame: frame)
        self.type = type
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        backgroundColor = .custom(.gray_f6f8fd)
        addSubview(roundedTop)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        containerView.addSubview(plusButton)
        
        roundedTop.frame.size = CGSize(width: Screen.screenWidth - ZTScaleValue(30), height: ZTScaleValue(10))
        roundedTop.addRounded(corners: [.topLeft, .topRight], radii: CGSize(width: ZTScaleValue(5), height: ZTScaleValue(5)), borderWidth: 0, borderColor: .custom(.white_ffffff))
        
        if type == .condition {
            titleLabel.text = "如果".localizedString
            detailLabel.text = "满足任意条件时".localizedString
        } else {
            titleLabel.text = "就执行".localizedString
        }

    }
    
    private func setupConstraints() {
        roundedTop.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview().offset(ZTScaleValue(10))
            $0.height.equalTo(ZTScaleValue(10))
        }

        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(roundedTop.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ZTScaleValue(7))
            $0.width.height.equalTo(ZTScaleValue(18))
            $0.right.equalToSuperview().offset(ZTScaleValue(-14.5))
        }

        if type == .action {
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(ZTScaleValue(7.5))
                $0.left.equalToSuperview().offset(ZTScaleValue(15.5))
                $0.right.equalTo(plusButton.snp.left).offset(ZTScaleValue(-15))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-15.5))
            }
        } else {
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.left.equalToSuperview().offset(ZTScaleValue(15.5))
                $0.right.equalTo(plusButton.snp.left).offset(ZTScaleValue(-15))
                
            }
            
            detailLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(3.5))
                $0.left.equalTo(titleLabel.snp.left)
                $0.right.equalTo(titleLabel.snp.right)
                $0.height.equalTo(ZTScaleValue(12))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-9))
            }
        }
    }
    
}
