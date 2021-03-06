//
//  GlobalLoadingView.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/8.
//

import UIKit

class GlobalLoadingView: UIView {
    
    private var gifDuration = 0.0
    
    private var imgs = [UIImage]()
    
    lazy var logoImgView = UIImageView().then {
        
        let path = Bundle.main.path(forResource: "loding", ofType: "gif")
        let data = NSData(contentsOfFile: path!)
        imgs = praseGIFDataToImageArray(data: data!)
        $0.contentMode = .scaleAspectFit
        $0.image = imgs.first
        $0.animationImages = imgs
    }
    
    lazy var bgView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff).withAlphaComponent(0.6)
        $0.layer.cornerRadius = ZTScaleValue(10)
        $0.layer.masksToBounds = true
    }
    
    lazy var lodingTitle = UILabel().then{
        $0.text = "Loding..."
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.backgroundColor = .clear
    }

    lazy var containerView = UIView().then {
        $0.backgroundColor = UIColor.custom(.black_333333).withAlphaComponent(0.2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(bgView)
        bgView.addSubview(lodingTitle)
        bgView.addSubview(logoImgView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(140))
        }
        
        logoImgView.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(30))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ZTScaleValue(60))
        }
        
        lodingTitle.snp.makeConstraints {
            $0.centerX.equalTo(logoImgView)
            $0.bottom.equalTo(-ZTScaleValue(20))
        }

        
//        containerView.makeToastActivity(.center)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func show() {
        SceneDelegate.shared.window?.addSubview(_globalLoadingViewInstance)
        _globalLoadingViewInstance.logoImgView.startAnimating()
    }
    
    static func hide() {
        _globalLoadingViewInstance.logoImgView.stopAnimating()
        _globalLoadingViewInstance.removeFromSuperview()
    }

}

extension GlobalLoadingView {
    private func praseGIFDataToImageArray(data:CFData) -> [UIImage]{
        
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else {
                    return []
                }
        // ??????gif??????
        let frameCount = CGImageSourceGetCount(imageSource)
        var images = [UIImage]()

        for i in 0 ..< frameCount {
            // ?????????????????? CGImage
            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
                return []
            }
            if frameCount == 1 {
                // ??????
                gifDuration = Double.infinity
            } else{
                // gif ??????
                // ????????? gif??????????????????
                guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) , let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                      let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else
                {
                    return []
                }
        //                print(frameDuration)
                gifDuration += frameDuration.doubleValue
                // ????????????img
                let  image = UIImage(cgImage: imageRef , scale: UIScreen.main.scale , orientation: UIImage.Orientation.up)
                // ???????????????
                images.append(image)
            }
        }
        return images
    }

}

let _globalLoadingViewInstance = GlobalLoadingView(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
