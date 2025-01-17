//
//  GPUImageProcessController.swift
//  GPUImage3Example
//
//  Created by Ja on 2025/1/17.
//

import UIKit
import ZLPhotoBrowser

class GPUImageProcessController: UIViewController {
    
    var originImage = UIImage(named: "org_passport.png")
    
    let scrollView = UIScrollView()
    
    let chooseImageButton = UIButton(type: .system)
    let resetButton = UIButton(type: .system)
    let comparisonButton = UIButton(type: .system)
    let processButton = UIButton(type: .system)
    
    var optionButtons: [UIButton] = []
    
    let displayImageView = UIImageView()
    
    var handledImage: UIImage?
    
    var processView: ProcessView?
    
    let optionButtonBaseTag: Int = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        resetButton.frame = CGRect(x: 20, y: 30, width: 80, height: 40)
        resetButton.setTitle("恢复原图", for: .normal)
        resetButton.addTarget(self, action: #selector(resetImage), for: .touchUpInside)
        view.addSubview(resetButton)
        
        chooseImageButton.center.x = view.center.x
        chooseImageButton.center.y = resetButton.center.y
        chooseImageButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        chooseImageButton.setTitle("选择相册照片", for: .normal)
        chooseImageButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        view.addSubview(chooseImageButton)
        
        comparisonButton.frame = CGRect(x: view.frame.maxX - 20 - 80, y: 30, width: 80, height: 40)
        comparisonButton.setTitle("长按对比", for: .normal)
        let long = UILongPressGestureRecognizer(target: self, action: #selector(comparison))
        comparisonButton.addGestureRecognizer(long)
        view.addSubview(comparisonButton)
        
        processButton.frame = CGRect(x: (view.frame.maxX - 140)/2, y: comparisonButton.frame.maxY, width: 140, height: 40)
        processButton.setTitle("开始处理图片", for: .normal)
        processButton.addTarget(self, action: #selector(beginProcess), for: .touchUpInside)
        view.addSubview(processButton)
        
        var lastView: UIView = resetButton
        
        let buttonsPerRow = 2 // 每行显示2个按钮
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 0 // 间隔大小
        
        for (index, option) in OptionEnableStorage.allOptions.enumerated() {
            
            let title = option.title
            
            let row = index / buttonsPerRow // 行号
            let column = index % buttonsPerRow // 列号
            
            let x = resetButton.frame.minX + CGFloat(column) * (buttonWidth + spacing)
            let y = processButton.frame.maxY + 8 + CGFloat(row) * (buttonHeight + spacing)
            
            let enabled = UserDefaults.standard.bool(forKey: option.key)
            
            let optionButton = UIButton(type: .custom)
            optionButton.isSelected = enabled
            optionButton.tag = optionButtonBaseTag + index
            optionButton.backgroundColor = .clear
            optionButton.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            optionButton.setTitle("添加\(title)", for: .normal)
            optionButton.setTitleColor(.systemBlue, for: .normal)
            optionButton.titleLabel?.font = comparisonButton.titleLabel?.font
            optionButton.setImage(UIImage(named: "option_normal"), for: .normal)
            optionButton.setImage(UIImage(named: "option_selected"), for: .selected)
            optionButton.contentHorizontalAlignment = .left
            optionButton.addTarget(self, action: #selector(enableOption(sender:)), for: .touchUpInside)
            view.addSubview(optionButton)
            
            lastView = optionButton
        }

        scrollView.frame = CGRect(x: 0, y: lastView.frame.maxY, width: view.bounds.size.width, height: 1000)
        view.addSubview(scrollView)
        
        displayImageView.image = originImage
        let imageWidth = UIScreen.main.bounds.size.width - 20 * 2
        let radio: CGFloat = (displayImageView.image?.size.width ?? 0) / (displayImageView.image?.size.height ?? 1)
        displayImageView.contentMode = .scaleAspectFill
        displayImageView.frame = CGRect(x: 20, y: 0, width: imageWidth, height: imageWidth / radio)
        scrollView.addSubview(displayImageView)
        
        scrollView.frame.size.height = displayImageView.bounds.size.height
        
        scrollView.contentSize = CGSize(width: 0, height: scrollView.frame.size.height + 200)
    }

}

extension GPUImageProcessController {
    
    @objc
    func enableOption(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        let index = sender.tag - optionButtonBaseTag
        
        if index == OptionEnableStorage.luminance.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.luminance.key)
        } else if index == OptionEnableStorage.sobelEdgeDetection.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.sobelEdgeDetection.key)
        } else if index == OptionEnableStorage.prewittEdgeDetection.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.prewittEdgeDetection.key)
        } else if index == OptionEnableStorage.thresholdSobelEdgeDetectionRange.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.thresholdSobelEdgeDetectionRange.key)
        } else if index == OptionEnableStorage.thresholdSobelEdgeDetectionThreshold.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.thresholdSobelEdgeDetectionThreshold.key)
        } else if index == OptionEnableStorage.halftone.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.halftone.key)
        } else if index == OptionEnableStorage.crosshatchSpace.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.crosshatchSpace.key)
        } else if index == OptionEnableStorage.crosshatchWidth.rawValue {
            UserDefaults.standard.set(sender.isSelected, forKey: OptionEnableStorage.crosshatchWidth.key)
        }
        
        UserDefaults.standard.synchronize()
        
        processView?.configScrollViewSubviews()
        processView?.dismiss()
    }
    
    @objc
    func beginProcess() {
        if processView == nil {
            processView = ProcessView(originImage: originImage!, topEnableSpace: processButton.frame.maxY, processCompletion: { [weak self] processedImage in
                guard let self = self else { return }
                
                self.displayImageView.image = processedImage
                self.handledImage = processedImage
            })
        }
        
        if let processView = processView, Utils.keyWindow().subviews.contains(processView) {
            return
        }
        processView?.show()
    }
    
    @objc
    func resetImage() {
        displayImageView.image = originImage
        handledImage = nil
        
        processView?.resetImage()
    }
    
    @objc
    func comparison(long: UILongPressGestureRecognizer) {
        switch long.state {
        case .began:
            displayImageView.image = originImage
        case .ended:
            if let handledImage = handledImage {
                displayImageView.image = handledImage
            }
        default: break
        }
    }
    
    
    @objc
    func chooseImage() {
        processView?.dismiss()
        
        let config = ZLPhotoConfiguration.default()
        config.maxSelectCount = 1
        config.allowSelectVideo = false
        config.allowSelectImage = true
        config.allowMixSelect = false
 
        let editImageConfiguration = config.editImageConfiguration
        editImageConfiguration.tools([.clip]).clipRatios([.wh1x1])
        
        let uiConfig = ZLPhotoUIConfiguration.default()
        uiConfig.style = .embedAlbumList
        
        let sheet = ZLPhotoPreviewSheet()
        sheet.selectImageBlock = { models, isFullImage in
            DispatchQueue.main.async {
                if let first = models.first?.image {
                    
                    let imageWidth = UIScreen.main.bounds.size.width - 20 * 2
                    let radio: CGFloat = first.size.width / first.size.height
                    self.displayImageView.image = first
                    self.originImage = first
                    self.processView?.originImage = first
                    
                    self.displayImageView.frame = CGRect(x: 20, y: 10, width: imageWidth, height: imageWidth / radio)
                    
                    self.scrollView.frame.size.height = self.displayImageView.bounds.size.height
                    
                    self.scrollView.contentSize = CGSize(width: 0, height: self.scrollView.frame.size.height + 200)
                    
                    self.resetImage()
                }
            }
        }
        sheet.showPhotoLibrary(sender: self)
    }
}
