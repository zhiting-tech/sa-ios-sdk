//
//  DiscoverHeader.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit

class DiscoverHeader: UIView {
    enum Status {
        case searching
        case failed
    }

    var status: Status? {
        didSet {
            guard let status = status else { return }
            timer?.invalidate()
            timer2?.invalidate()
            
            dot2?.removeFromSuperview()
            
            dot4?.removeFromSuperview()
            
            dot6?.removeFromSuperview()
            
            switch status {
            case .searching:
                startAnimating()
                failedImage.isHidden = true
            case .failed:
                titleLabel.text = "未发现设备".localizedString
                failedImage.isHidden = false
                roatateImage.transform = .identity
            }
        }
    }
    
    private var timer: Timer?
    private var timer2: Timer?

    private lazy var bgImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.discoverBG1)
    }
    
    
    private var dot2: Dot?
    private var dot4: Dot?
    private var dot6: Dot?

    
    private lazy var roatateImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.discoverBG2)
    }
    
    private lazy var failedImage = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.exclamation_mark)
        $0.isHidden = true
    }

    private lazy var titleLabel = Label().then {
        $0.font = .font(size: 16, type: .bold)
        $0.text = "正在扫描".localizedString
        $0.textAlignment = .center
        $0.textColor = .custom(.gray_94a5be)
    }
    
    private lazy var descriptionLabel = Label().then {
        $0.numberOfLines = 0
        $0.font = .font(size: 13, type: .regular)
        $0.text = "1.请确保设备已连接电源，且已重置;".localizedString + "\n" + "2.第一次添加某品牌的设备时，请进入【我-支持品牌】添加该品牌".localizedString
        $0.textColor = .custom(.gray_94a5be)
        $0.lineBreakMode = .byWordWrapping
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .custom(.white_ffffff)
        addSubview(bgImage)
        addSubview(roatateImage)
        
        addSubview(failedImage)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
    }
    
    private func setConstrains() {
        bgImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(31.5)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(Screen.screenWidth*0.46)
        }
        
        roatateImage.snp.makeConstraints {
            $0.edges.equalTo(bgImage.snp.edges)
        }
        
        failedImage.snp.makeConstraints {
            $0.center.equalTo(bgImage.snp.center)
            $0.width.equalTo(18)
            $0.height.equalTo(72)
        }
        
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(bgImage.snp.bottom).offset(22.5)
            $0.height.equalTo(18)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(15).priority(.high)
            $0.right.equalToSuperview().offset(-15).priority(.high)
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-19.5))
        }
        


    }
    
    
    private func startAnimating() {
        
        dot2 = Dot(frame: CGRect(x: 0, y: 0, width: 4, height: 4), alpha: 0)
        dot4 = Dot(frame: CGRect(x: 0, y: 0, width: 5, height: 5), alpha: 0)
        dot6 = Dot(frame: CGRect(x: 0, y: 0, width: 7, height: 7), alpha: 0)
        
        bgImage.addSubview(dot2!)
        bgImage.addSubview(dot4!)
        bgImage.addSubview(dot6!)
        
        dot2?.snp.makeConstraints {
            $0.height.width.equalTo(4.5)
            $0.centerX.equalToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(43)
        }
        
        
        
        
        dot4?.snp.makeConstraints {
            $0.height.width.equalTo(5)
            $0.centerX.equalToSuperview().offset(35)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        
        
        dot6?.snp.makeConstraints {
            $0.height.width.equalTo(7)
            $0.centerY.equalToSuperview().offset(-18.5)
            $0.right.equalToSuperview().offset(-25)
        }
        
        var count = 1
        timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            count += 1
            var str = "正在扫描".localizedString
            for _ in 0..<count % 4 {
                str += "."
            }
            self.titleLabel.text = str
            
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        
        var count2: CGFloat = 0
        timer2 = Timer(timeInterval: 0.01, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            count2 += 0.03
            self.roatateImage.transform = CGAffineTransform.init(rotationAngle: CGFloat(count2))
        })
        timer2?.fire()
        RunLoop.main.add(timer2!, forMode: .common)

        


        UIView.animate(withDuration: 0.7, delay: 1, options: [.repeat, .curveEaseInOut, .autoreverse], animations: { [weak self] in
            guard let self = self else { return }
            self.dot2?.isHidden = false
            self.dot2?.alpha = 1
        })
        

        
        UIView.animate(withDuration: 1, delay: 2, options: [.repeat, .curveEaseInOut, .autoreverse], animations: { [weak self] in
            guard let self = self else { return }
            self.dot4?.isHidden = false
            self.dot4?.alpha = 1
        })
        

        
        UIView.animate(withDuration: 0.8, delay: 4, options: [.repeat, .curveEaseInOut, .autoreverse], animations: { [weak self] in
            guard let self = self else { return }
            self.dot6?.isHidden = false
            self.dot6?.alpha = 1
        })
        
    }

}



extension DiscoverHeader {
    class Dot: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
            backgroundColor = .custom(.blue_2da3f6)
        }
        
        convenience init(frame: CGRect, alpha: CGFloat) {
            self.init(frame: frame)
            self.alpha = alpha
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
