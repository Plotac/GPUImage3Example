//
//  Configs.swift
//  GPUImage3Example
//
//  Created by Ja on 2025/1/17.
//

import Foundation

enum AdjustmentType: Int {
    case contrast = 0,
         brightness,
         saturation,
         exposure,
         sharpness,
         shadow,
         highlight,
//         whiteBalance,
         gamma,
         hue,
//         hazeIntensity,
//         hazeSlope,
//         redColor,
//         greenColor,
//         blueColor,
         opacity,
         luminanceThreshold,
         vibrance,
         sobelEdgeDetection,
         prewittEdgeDetection,
         thresholdSobelEdgeDetectionRange,
         thresholdSobelEdgeDetectionThreshold,
         halftone,
         crosshatchSpace,
         crosshatchWidth
    
    var info: (title: String, defaultValue: Float, min: Float, max: Float) {
        switch self {
        case .contrast: ("对比度", 1, 0, 4)
        case .brightness: ("亮度", 0, -1, 1)
        case .saturation: ("饱和度", 1, 0, 2)
        case .exposure: ("曝光度", 0, -10, 10)
        case .sharpness: ("锐化", 0, -4, 4)
        case .shadow: ("阴影", 0, 0, 1)
        case .highlight: ("高光", 1, 0, 1)
//        case .whiteBalance: ("白平衡", 5000, 3000, 7000)
        case .gamma: ("伽马值", 1, 0, 3)
        case .hue: ("色调(角度)", 0, 0, 90)
//        case .hazeIntensity: ("雾霾强度", 0, -3, 3)
//        case .hazeSlope: ("雾霾斜率", 0, -3, 3)
//        case .redColor: ("红", 1, 0, 1)
//        case .greenColor: ("绿",  1, 0, 1)
//        case .blueColor: ("蓝",  1, 0, 1)
        case .opacity: ("透明度",  1, 0, 1)
        case .luminanceThreshold: ("像素亮度", 0.5, 0, 1)
        case .vibrance: ("自然饱和度", 0, -1.2, 1.2)
        case .sobelEdgeDetection: ("Sobel边缘检测", 1, -10, 10)
        case .prewittEdgeDetection: ("Prewitt边缘检测", 1, -10, 10)
        case .thresholdSobelEdgeDetectionRange: ("Threshold边缘检测范围", 1, -100, 100)
        case .thresholdSobelEdgeDetectionThreshold: ("Threshold边缘检测阈值", 0.8, 0.0, 1.0)
        case .halftone: ("半色调", 0.05, 0, 1.0)
        case .crosshatchSpace: ("交叉影线间距图像分数宽度", 0.03, 0.0, 1.0)
        case .crosshatchWidth: ("交叉影线相对宽度", 0.03, 0.0, 1.0)
        }
    }
    static func allTypes() -> [AdjustmentType] {
        let base = [AdjustmentType.contrast,
                    AdjustmentType.brightness,
                    AdjustmentType.saturation,
                    AdjustmentType.exposure,
                    AdjustmentType.sharpness,
                    AdjustmentType.shadow,
                    AdjustmentType.highlight,
                    //         AdjustmentType.whiteBalance,
                    AdjustmentType.gamma,
                    AdjustmentType.hue,
                    //         AdjustmentType.hazeIntensity,
                    //         AdjustmentType.hazeSlope,
                    //         AdjustmentType.redColor,
                    //         AdjustmentType.greenColor,
                    //         AdjustmentType.blueColor,
                    AdjustmentType.opacity,
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.luminance.key) ? AdjustmentType.luminanceThreshold : nil),
                    AdjustmentType.vibrance,
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.sobelEdgeDetection.key) ? AdjustmentType.sobelEdgeDetection : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.prewittEdgeDetection.key) ? AdjustmentType.prewittEdgeDetection : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.thresholdSobelEdgeDetectionRange.key) ? AdjustmentType.thresholdSobelEdgeDetectionRange : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.thresholdSobelEdgeDetectionThreshold.key) ? AdjustmentType.thresholdSobelEdgeDetectionThreshold : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.halftone.key) ? AdjustmentType.halftone : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.crosshatchSpace.key) ? AdjustmentType.crosshatchSpace : nil),
                    (UserDefaults.standard.bool(forKey: OptionEnableStorage.crosshatchWidth.key) ? AdjustmentType.crosshatchWidth : nil)
        ]
        
        return base.compactMap { $0 }
    }
    
    static func allItems() -> [AdjustmentItem] {
        return allTypes().map { AdjustmentItem(title: $0.info.title,
                                               type: $0,
                                               config: Config(defaultValue: $0.info.defaultValue,
                                                              min: $0.info.min,
                                                              max: $0.info.max)) }
    }
}

struct AdjustmentItem {
    let title: String
    let type: AdjustmentType
    let config: Config
}

struct Config {
    let defaultValue: Float
    let min: Float
    let max: Float
}

enum OptionEnableStorage: Int {
    case luminance = 0
    case sobelEdgeDetection
    case prewittEdgeDetection
    case thresholdSobelEdgeDetectionRange
    case thresholdSobelEdgeDetectionThreshold
    case halftone
    case crosshatchSpace
    case crosshatchWidth
    
    static var allOptions: [OptionEnableStorage] {
        [
            .luminance,
            .sobelEdgeDetection,
            .prewittEdgeDetection,
            .thresholdSobelEdgeDetectionRange,
            .thresholdSobelEdgeDetectionThreshold,
            .halftone,
            .crosshatchSpace,
            .crosshatchWidth
        ]
    }
    
    var key: String {
        switch self {
        case .luminance: return "OptionEnableStorage.luminance"
        case .sobelEdgeDetection: return "OptionEnableStorage.sobelEdgeDetection"
        case .prewittEdgeDetection: return "OptionEnableStorage.prewittEdgeDetection"
        case .thresholdSobelEdgeDetectionRange: return "OptionEnableStorage.thresholdSobelEdgeDetectionRange"
        case .thresholdSobelEdgeDetectionThreshold: return "OptionEnableStorage.thresholdSobelEdgeDetectionThreshold"
        case .halftone: return "OptionEnableStorage.halftone"
        case .crosshatchSpace: return "OptionEnableStorage.crosshatchSpace"
        case .crosshatchWidth: return "OptionEnableStorage.crosshatchWidth"
        }
    }
    
    var title: String {
        switch self {
        case .luminance: "像素亮度"
        case .sobelEdgeDetection: "Sobel边缘检测"
        case .prewittEdgeDetection: "Prewitt边缘检测"
        case .thresholdSobelEdgeDetectionRange: "Threshold范围"
        case .thresholdSobelEdgeDetectionThreshold: "Threshold阈值"
        case .halftone: "半色调"
        case .crosshatchSpace: "交叉影线分数宽度"
        case .crosshatchWidth: "交叉影线相对宽度"
        }
    }
}
