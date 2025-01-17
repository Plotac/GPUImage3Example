//
//  Utils.swift
//  GPUImage3Example
//
//  Created by Ja on 2025/1/17.
//

import UIKit

struct Utils {
    static func keyWindow() -> UIWindow {
        let firstActiveWindows: [UIWindow]? = foregroundActiveWindowScenes().first?.windows
        let keyWindow: UIWindow? = firstActiveWindows?.first { $0.isKeyWindow }
        return keyWindow ?? firstWindow()
    }
    
    static func firstWindow() -> UIWindow {
            return ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first)!
        }
    
    static func foregroundActiveWindowScenes() -> [UIWindowScene] {
        let scenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        return scenes
    }
}

extension Array {
    func safeIndex(index: Int) -> Element? {
        if index < 0 { return nil }
    
        if index < count {
            return self[index]
        }
        return nil
    }
}

extension UIColor {
    
    class func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let length = (cString as NSString).length
        if (length < 6 || length > 7 || (!cString.hasPrefix("#") && length == 7)) {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        
        var range = NSRange()
        range.location = 0
        range.length = 2
        
        let rString = (cString as NSString).substring(with: range)
        
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)
        
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    
    func toHexString() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
        
        let r = Int(red * 255.0)
        let g = Int(green * 255.0)
        let b = Int(blue * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension String {
    func strSize(font: UIFont) -> CGSize {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFLOAT_MAX, height: CGFLOAT_MAX), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
    }
}
