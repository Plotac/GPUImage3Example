//
//  ProcessView.swift
//  GPUImage3Example
//
//  Created by Ja on 2025/1/17.
//

import UIKit
import SnapKit

class ProcessView: UIView {
    let scrollView = UIScrollView()
    
    var originImage: UIImage! {
        didSet {
            resetImage()
        }
    }
    
    var pictureInput: PictureInput?
    var pictureOutput: PictureOutput?
    
    var items: [AdjustmentItem] = []
    
    private let processCompletion: (_ processedImage: UIImage) -> Void
    
    private var lastView: UIView
    
    private let topSpacing: CGFloat
    private let containerHeight: CGFloat = 300
    
    private let sliderBaseTag: Int = 1000
    private let titleBaseTag: Int = 2000
    private let resetBaseTag: Int = 3000
    private let currentValueBaseTag: Int = 4000
    private let titleCurrentValueBaseTag: Int = 5000
    private let valueTFBaseTag: Int = 6000
    private let confirmValueBaseTag: Int = 7000
    
    init(originImage: UIImage, topEnableSpace: CGFloat, processCompletion: @escaping (_ processedImage: UIImage) -> Void) {
        self.processCompletion = processCompletion
        self.lastView = scrollView
        self.topSpacing = topEnableSpace
        super.init(frame: CGRect(x: 0, y: topEnableSpace, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topEnableSpace))
       
        self.originImage = originImage
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.layer.cornerRadius = 10
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.contentSize = CGSize(width: 0, height: 3600)
        scrollView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + 10, width: UIScreen.main.bounds.width, height: containerHeight)
        scrollView.backgroundColor = UIColor(hex: "#F8F9FA")
        addSubview(scrollView)
        
        configScrollViewSubviews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    func configScrollViewSubviews() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        lastView = scrollView
        items = AdjustmentType.allItems()
        for (_, item) in items.enumerated() {
            let slider = UISlider()
            slider.tag = sliderBaseTag + item.type.rawValue
            slider.value = item.config.defaultValue
            slider.minimumValue = item.config.min
            slider.maximumValue = item.config.max
            
            build(item: item, currentSlider: slider, lastView: lastView)
            
            lastView = slider
        }
        
        for (_, item) in items.enumerated() {
            let label = UILabel()
            label.tag = currentValueBaseTag + item.type.rawValue
            label.text = text(for: item.type)
            label.textColor = .black
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textAlignment = .right
            
            scrollView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalTo(20)
                make.top.equalTo(lastView.snp.bottom).offset(10)
            }
            
            lastView = label
        }
    }
    
    @objc
    private func tapped() {
        dismiss()
    }
    
    func show() {
        let window = Utils.keyWindow()
        window.addSubview(self)
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            self.scrollView.frame.origin.y = UIScreen.main.bounds.height - self.topSpacing - self.containerHeight
        } completion: { _ in
        }
    }
    
    
    func dismiss() {
        UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.curveLinear) {
            self.scrollView.frame.origin.y = UIScreen.main.bounds.height + 10
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc
    func sliderValueChanged() {
        guard let originalImage = originImage else {
            fatalError("originImage can't be nil!!!")
        }
        
        let sliders = fetchSliders()
        
        guard sliders.count == items.count else {
            fatalError("The number of sliders must be the same as the items")
        }
        
        let contrastValue = fetchSlider(type: AdjustmentType.contrast)?.value ??  AdjustmentType.contrast.info.defaultValue
        let brightnessValue = fetchSlider(type: AdjustmentType.brightness)?.value ??  AdjustmentType.brightness.info.defaultValue
        let saturationValue = fetchSlider(type: AdjustmentType.saturation)?.value ??  AdjustmentType.saturation.info.defaultValue
        let exposureValue = fetchSlider(type: AdjustmentType.exposure)?.value ??  AdjustmentType.exposure.info.defaultValue
        let sharpnessValue = fetchSlider(type: AdjustmentType.sharpness)?.value ??  AdjustmentType.sharpness.info.defaultValue
        let shadowValue = fetchSlider(type: AdjustmentType.shadow)?.value ??  AdjustmentType.shadow.info.defaultValue
        let highlightValue = fetchSlider(type: AdjustmentType.highlight)?.value ??  AdjustmentType.highlight.info.defaultValue
//        let whiteBalanceValue = fetchSlider(type: AdjustmentType.whiteBalance)?.value ??  AdjustmentType.whiteBalance.info.defaultValue
        let gammaValue = fetchSlider(type: AdjustmentType.gamma)?.value ??  AdjustmentType.gamma.info.defaultValue
        let hueValue = fetchSlider(type: AdjustmentType.hue)?.value ??  AdjustmentType.hue.info.defaultValue
//        let hazeIntensityValue = fetchSlider(type: AdjustmentType.hazeIntensity)?.value ??  AdjustmentType.hazeIntensity.info.defaultValue
//        let hazeSlopeValue = fetchSlider(type: AdjustmentType.hazeSlope)?.value ??  AdjustmentType.hazeSlope.info.defaultValue
//        let redValue = fetchSlider(type: AdjustmentType.redColor)?.value ??  AdjustmentType.redColor.info.defaultValue
//        let greenValue = fetchSlider(type: AdjustmentType.greenColor)?.value ??  AdjustmentType.greenColor.info.defaultValue
//        let blueValue = fetchSlider(type: AdjustmentType.blueColor)?.value ??  AdjustmentType.blueColor.info.defaultValue
        let opacityValue = fetchSlider(type: AdjustmentType.opacity)?.value ??  AdjustmentType.opacity.info.defaultValue
        let luminanceThresholdValue = fetchSlider(type: AdjustmentType.luminanceThreshold)?.value ??  AdjustmentType.luminanceThreshold.info.defaultValue
        let vibranceValue = fetchSlider(type: AdjustmentType.vibrance)?.value ??  AdjustmentType.vibrance.info.defaultValue
        let sobelStrengthValue = fetchSlider(type: AdjustmentType.sobelEdgeDetection)?.value ??  AdjustmentType.sobelEdgeDetection.info.defaultValue
        let prewittStrengthValue = fetchSlider(type: AdjustmentType.prewittEdgeDetection)?.value ??  AdjustmentType.prewittEdgeDetection.info.defaultValue
        let thresholdSobelStrengthValue = fetchSlider(type: AdjustmentType.thresholdSobelEdgeDetectionRange)?.value ??  AdjustmentType.thresholdSobelEdgeDetectionRange.info.defaultValue
        let tSobelThresholdValue = fetchSlider(type: AdjustmentType.thresholdSobelEdgeDetectionThreshold)?.value ??  AdjustmentType.thresholdSobelEdgeDetectionThreshold.info.defaultValue
        let fractionalWidthOfAPixelValue = fetchSlider(type: AdjustmentType.halftone)?.value ??  AdjustmentType.halftone.info.defaultValue
        let crossHatchSpacingValueValue = fetchSlider(type: AdjustmentType.crosshatchSpace)?.value ??  AdjustmentType.crosshatchSpace.info.defaultValue
        let crosshatchWidthValue = fetchSlider(type: AdjustmentType.crosshatchWidth)?.value ??  AdjustmentType.crosshatchWidth.info.defaultValue
        enhanceImage(originalImage,
                     contrast: contrastValue,
                     brightness: brightnessValue,
                     saturation: saturationValue,
                     exposure: exposureValue,
                     sharpen: sharpnessValue,
                     shadow: shadowValue,
                     highlights: highlightValue,
//                     whiteBalance: whiteBalanceValue,
                     gamma: gammaValue,
                     hue: hueValue,
//                     hazeIntensity: hazeIntensityValue,
//                     hazeSlope: hazeSlopeValue,
//                     red: redValue,
//                     green: greenValue,
//                     blue: blueValue,
                     opacity: opacityValue,
                     luminanceThreshold: luminanceThresholdValue,
                     vibrance: vibranceValue,
                     sobelStrength: sobelStrengthValue,
                     prewittStrength: prewittStrengthValue,
                     thresholdSobelStrength: thresholdSobelStrengthValue,
                     tSobelThreshold: tSobelThresholdValue,
                     fractionalWidthOfAPixel: fractionalWidthOfAPixelValue,
                     crossHatchSpacing: crossHatchSpacingValueValue,
                     crossHatchLineWidth: crosshatchWidthValue
        )
        
        let tValueLabels = fetchTitleValueLabels()
        let valueLabels = fetchBottomValueLabels()
        let tfs = fetchTextfields()

        guard tValueLabels.count == items.count,
              sliders.count == items.count,
              tfs.count == items.count,
              valueLabels.count == items.count else {
            fatalError("The number of controls must be the same as the items")
        }
        
        for (index, label) in valueLabels.enumerated() {
            let item = items[index]
            label.text = text(for: item.type)
        }
        
        for (index, label) in tValueLabels.enumerated() {
            let item = items[index]
            
            if let slider = fetchSlider(type: item.type) {
                label.text = "当前值：\(String(format: "%.4f", slider.value))"
            }
        }
        
        for (index, tf) in tfs.enumerated() {
            let item = items[index]
            
            if let slider = fetchSlider(type: item.type) {
                tf.text = "\(String(format: "%.4f", slider.value))"
            }
        }
    }
    
    @objc
    func resetSliderValue(sender: UIButton) {
        let sliders = fetchSliders()
        let resetButtons = fetchResetButtons()
        
        guard sliders.count == items.count else {
            fatalError("The number of sliders must be the same as the items")
        }
        
        guard resetButtons.count == items.count else {
            fatalError("The number of resetButtons must be the same as the items")
        }
        
        let index = sender.tag - resetBaseTag
        
        if let item = items.first(where: { $0.type.rawValue == index }) {
            if let slider = fetchSlider(type: item.type) {
                slider.value = item.config.defaultValue
            }
        }
        
        sliderValueChanged()
    }
    
    @objc
    func resetImage() {
        
        let sliders = fetchSliders()
        let tValueLabels = fetchTitleValueLabels()
        let valueLabels = fetchBottomValueLabels()
        let tfs = fetchTextfields()

        guard tValueLabels.count == items.count,
              sliders.count == items.count,
              tfs.count == items.count,
              valueLabels.count == items.count else {
            fatalError("The number of controls must be the same as the items")
        }
        
        for (index, label) in tValueLabels.enumerated() {
            let item = items[index]
            label.text = "当前值：\(String(format: "%.4f", item.config.defaultValue))"
        }
        
        for (index, slider) in sliders.enumerated() {
            let item = items[index]
            slider.value = item.config.defaultValue
        }
        
        for (index, tf) in tfs.enumerated() {
            let item = items[index]
            tf.text = "\(String(format: "%.4f", item.config.defaultValue))"
        }
        
        for (index, label) in valueLabels.enumerated() {
            let item = items[index]
            label.text = text(for: item.type)
        }

    }
}

extension ProcessView {
    
    func enhanceImage(_ image: UIImage,
                      contrast: Float,
                      brightness: Float,
                      saturation: Float,
                      exposure: Float,
                      sharpen: Float,
                      shadow: Float,
                      highlights: Float,
//                      whiteBalance: Float,
                      gamma: Float,
                      hue: Float,
//                      hazeIntensity: Float,
//                      hazeSlope: Float,
//                      red: Float,
//                      green: Float,
//                      blue: Float,
                      opacity: Float,
                      luminanceThreshold: Float,
                      vibrance: Float,
                      sobelStrength: Float,
                      prewittStrength: Float,
                      thresholdSobelStrength: Float,
                      tSobelThreshold: Float,
                      fractionalWidthOfAPixel: Float,
                      crossHatchSpacing: Float,
                      crossHatchLineWidth: Float) {
        
        pictureInput = PictureInput(image: image)
        
        pictureOutput = PictureOutput()
        pictureOutput?.imageAvailableCallback = { [weak self] processedImage in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.processCompletion(processedImage)
                self.pictureOutput = nil
            }
        }
        
        // 对比度滤镜
        let contrastFilter = ContrastAdjustment()
        contrastFilter.contrast = contrast // 增加对比度，范围[0.0 - 4.0]，默认1.0
        
        // 亮度滤镜
        let brightnessFilter = BrightnessAdjustment()
        brightnessFilter.brightness = brightness // 调整亮度，范围 [-1.0, - 1.0]，默认0.0
        
        // 饱和度滤镜
        let saturationFilter = SaturationAdjustment()
        saturationFilter.saturation = saturation // 调整饱和度，范围 [0.0, - 2.0]，默认值为 1.0
        
        // 曝光度滤镜
        let exposureFilter = ExposureAdjustment()
        exposureFilter.exposure = exposure
        
        // 锐化滤镜
        let sharpenFilter = Sharpen()
        sharpenFilter.sharpness = sharpen // 调整锐化程度，范围[-4.0 - 4.0]，默认0.0
        
        // 高光阴影滤镜
        let highlightShadowFilter = HighlightsAndShadows()
        highlightShadowFilter.shadows = shadow // 阴影，范围 [0.0 - 1.0]，默认0.0
        highlightShadowFilter.highlights = highlights // 高光，范围 [1.0 - 0.0]，默认1.0
        
        // 白平衡
//        let whiteBalanceFilter = WhiteBalance()
//        whiteBalanceFilter.temperature = whiteBalance
        
        // 伽马值
        let gammaFilter = GammaAdjustment()
        gammaFilter.gamma = gamma
        
        // 色调
        let _hue = HueAdjustment()
        _hue.hue = hue
        
        // 雾霾
//        let haze = Haze()
//        haze.distance = hazeIntensity
//        haze.slope = hazeSlope
        
        // RGB调整
//        let rgbFilter = RGBAdjustment()
//        rgbFilter.red = red
//        rgbFilter.green = green
//        rgbFilter.blue = blue
        
        // 透明度
        let opacityFilter = OpacityAdjustment()
        opacityFilter.opacity = opacity
        
        // 像素亮度（亮度高于阈值的像素将显示为白色，低于阈值的像素将显示为黑色）
        let luminanceThresholdFilter = LuminanceThreshold()
        luminanceThresholdFilter.threshold = luminanceThreshold
        
        // 自然饱和度
        let vibranceFilter = Vibrance()
        vibranceFilter.vibrance = vibrance
        
        // sobel边缘检测
        let sobel = SobelEdgeDetection()
        sobel.edgeStrength = sobelStrength
        
        // prewitt边缘检测
        let prewitt = PrewittEdgeDetection()
        prewitt.edgeStrength = prewittStrength
        
        // sobel边缘检测（阈值）
        let thresholdSobel = ThresholdSobelEdgeDetection()
        thresholdSobel.edgeStrength = thresholdSobelStrength
        thresholdSobel.threshold = tSobelThreshold
        
        // 半色调
        let halftone = Halftone()
        halftone.fractionalWidthOfAPixel = fractionalWidthOfAPixel
        
        // 交叉影线
        let crosshatch = Crosshatch()
        crosshatch.crossHatchSpacing = crossHatchSpacing
        crosshatch.lineWidth = crossHatchLineWidth
        
        guard let pictureInput = pictureInput, let pictureOutput = pictureOutput else {
            return
        }
        
        let hasLuminance = UserDefaults.standard.bool(forKey: OptionEnableStorage.luminance.key)
        let hasSobelEdgeDetection = UserDefaults.standard.bool(forKey: OptionEnableStorage.sobelEdgeDetection.key)
        let hasPrewittEdgeDetection = UserDefaults.standard.bool(forKey: OptionEnableStorage.prewittEdgeDetection.key)
        let hasThresholdSobelEdgeDetectionRange = UserDefaults.standard.bool(forKey: OptionEnableStorage.thresholdSobelEdgeDetectionRange.key)
        let hasThresholdSobelEdgeDetectionThreshold = UserDefaults.standard.bool(forKey: OptionEnableStorage.thresholdSobelEdgeDetectionThreshold.key)
        let hasHalftone = UserDefaults.standard.bool(forKey: OptionEnableStorage.halftone.key)
        let hasCrosshatchSpace = UserDefaults.standard.bool(forKey: OptionEnableStorage.crosshatchSpace.key)
        let hasCrosshatchWidth = UserDefaults.standard.bool(forKey: OptionEnableStorage.crosshatchWidth.key)
        
        // 串联滤镜
        pictureInput
        --> contrastFilter
        --> brightnessFilter
        --> saturationFilter
        --> exposureFilter
        --> sharpenFilter
        --> highlightShadowFilter
//        --> whiteBalanceFilter
        --> gammaFilter
        --> _hue
//        --> haze
//        --> rgbFilter
        --> opacityFilter
        
        var source: ImageSource = opacityFilter
        
        if hasLuminance {
            source.addTarget(luminanceThresholdFilter)
            source = luminanceThresholdFilter
        }
        
        if hasSobelEdgeDetection {
            source.addTarget(sobel)
            source = sobel
        }
        
        if hasPrewittEdgeDetection {
            source.addTarget(prewitt)
            source = prewitt
        }
        
        if hasThresholdSobelEdgeDetectionRange || hasThresholdSobelEdgeDetectionThreshold {
            source.addTarget(thresholdSobel)
            source = thresholdSobel
        }
        
        if hasHalftone {
            source.addTarget(halftone)
            source = halftone
        }
        
        if hasCrosshatchSpace || hasCrosshatchWidth {
            source.addTarget(crosshatch)
            source = crosshatch
        }
        
        source
        --> vibranceFilter
        --> pictureOutput
        
        // 开始处理图片
        pictureInput.processImage()
    }
    
    func text(for type: AdjustmentType) -> String {
        if let slider = fetchSlider(type: type) {
            return "\(type.info.title):   \(String(format: "%.4f", slider.value))"
        }
        return "\(type.info.title):   0.000"
    }
    
    func build(item: AdjustmentItem, currentSlider: UISlider, lastView: UIView) {
        
        let lab = UILabel()
        lab.tag = titleBaseTag + item.type.rawValue
        lab.text = item.title + "(\(item.config.min) ~ \(item.config.max)，默认\(item.config.defaultValue))"
        lab.textColor = .black
        lab.font = .systemFont(ofSize: 15)
        scrollView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(lastView.snp.bottom).offset(20)
        }
        
        let currentValueLab = UILabel()
        currentValueLab.tag = titleCurrentValueBaseTag + item.type.rawValue
        currentValueLab.text = "当前值：\(String(format: "%.4f", item.config.defaultValue))"
        currentValueLab.textColor = .black
        currentValueLab.font = .systemFont(ofSize: 15)
        scrollView.addSubview(currentValueLab)
        currentValueLab.snp.makeConstraints { make in
            make.left.equalTo(lab)
            make.top.equalTo(lab.snp.bottom).offset(10)
        }
        
        let manualLab = UILabel()
        manualLab.text = "手动设置"
        manualLab.textColor = .black
        manualLab.font = .systemFont(ofSize: 15)
        scrollView.addSubview(manualLab)
        manualLab.snp.makeConstraints { make in
            make.left.equalTo(lab)
            make.top.equalTo(currentValueLab.snp.bottom).offset(10)
        }
        
        let valueTF = UITextField()
        valueTF.tag = valueTFBaseTag + item.type.rawValue
        valueTF.text = "\(String(format: "%.4f", item.config.defaultValue))"
        valueTF.textColor = .black
        valueTF.font = .systemFont(ofSize: 15)
        valueTF.layer.borderColor = UIColor.lightGray.cgColor
        valueTF.layer.borderWidth = 0.7
        valueTF.layer.cornerRadius = 5
        valueTF.keyboardType = .decimalPad
        let left = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        valueTF.leftView = left
        valueTF.leftViewMode = .always
        scrollView.addSubview(valueTF)
        valueTF.snp.makeConstraints { make in
            make.left.equalTo(manualLab.snp.right).offset(10)
            make.centerY.equalTo(manualLab)
            make.size.equalTo(CGSize(width: 100, height: 30))
        }
        
        let action = UIAction { [weak self] act in
            guard let self = self else { return }
            
            if let button = act.sender as? UIButton,
               let tf = scrollView.viewWithTag( button.tag - confirmValueBaseTag + valueTFBaseTag) as? UITextField,
               let slider = scrollView.viewWithTag( button.tag - confirmValueBaseTag + sliderBaseTag) as? UISlider {
                
                if tf.isFirstResponder {
                    tf.resignFirstResponder()
                }
                slider.value = Float(tf.text!)!
                
                sliderValueChanged()
            }
            
        }
        
        let confirmButton = UIButton(type: .system, primaryAction: action)
        confirmButton.tag = confirmValueBaseTag + item.type.rawValue
        confirmButton.setTitle("确定修改", for: .normal)
        scrollView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(valueTF.snp.right).offset(10)
            make.centerY.equalTo(valueTF)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        
        currentSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        scrollView.addSubview(currentSlider)
        currentSlider.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(manualLab.snp.bottom).offset(10)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
        
        let resetButton = UIButton(type: .system)
        resetButton.tag = resetBaseTag + item.type.rawValue
        resetButton.setTitle("重置", for: .normal)
        resetButton.addTarget(self, action: #selector(resetSliderValue(sender:)), for: .touchUpInside)
        scrollView.addSubview(resetButton)
        resetButton.snp.makeConstraints { make in
            make.right.equalTo(self.snp.right).inset(20)
            make.centerY.equalTo(currentSlider)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
}

extension ProcessView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: scrollView) {
            return false
        }
        return true
    }
}

extension ProcessView {
    func fetchSliders() -> [UISlider] {
        return scrollView.subviews.compactMap { $0 as? UISlider }
    }
    
    func fetchSlider(type: AdjustmentType) -> UISlider? {
        return scrollView.viewWithTag(type.rawValue + sliderBaseTag) as? UISlider
    }
    
    func fetchResetButtons() -> [UIButton] {
        return scrollView.subviews.compactMap { view in
            let tag = (view as? UIButton)?.tag ?? 0
            if tag >= resetBaseTag, tag < confirmValueBaseTag {
                return view as? UIButton
            }
            return nil
        }
    }
    
    func fetchConfirmButtons() -> [UIButton] {
        return scrollView.subviews.compactMap { view in
            let tag = (view as? UIButton)?.tag ?? 0
            if tag >= confirmValueBaseTag {
                return view as? UIButton
            }
            return nil
        }
    }
    
    func fetchTitleValueLabels() -> [UILabel] {
        
        return scrollView.subviews.compactMap { view in
            if ((view as? UILabel)?.tag ?? 0) >= titleCurrentValueBaseTag {
                return view as? UILabel
            }
            return nil
        }
    }
    
    func fetchBottomValueLabels() -> [UILabel] {
        return scrollView.subviews.compactMap { view in
            let tag = (view as? UILabel)?.tag ?? 0
            if tag >= currentValueBaseTag , tag < titleCurrentValueBaseTag {
                return view as? UILabel
            }
            return nil
        }
    }
    
    func fetchTextfields() -> [UITextField] {
        return scrollView.subviews.compactMap { view in
            if ((view as? UITextField)?.tag ?? 0) >= valueTFBaseTag {
                return view as? UITextField
            }
            return nil
        }
    }
}
