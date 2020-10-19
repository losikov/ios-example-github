//
//  Colors.swift
//  GitHub
//
//  Created by Alexander Losikov on 10/17/20.
//  Copyright © 2020 Alexander Losikov. All rights reserved.
//

import UIKit

// MARK: - Colors

extension UIColor {
    
    public static var brandAero: UIColor = .init(hex: "#7DBBE6")
    
    public static var brandGiantsClub: UIColor = .init(hex: "#AD5C51")
    
    public static var primaryBackground: UIColor = .dynamicColor(
        light: .white,
        dark: .black
    )
    
    public static var secondaryBackground: UIColor = .dynamicColor(
        light: .init(hex: "#DDDFE1"),
        dark: .init(hex: "#14171A")
    )
    
}

// MARK: - Utility

extension UIColor {
    
    /// Initialize a color according to the hexadecimal string value
    /// - parameter hex: string representing the color in hexadecimal format (the hexadecimal string must be valid (including `#` and `6` hexadecimal digits)
    /// - parameter alpha: alpha value of the color to be generated
    public convenience init(hex: String, alpha: CGFloat = 1) {
        guard hex.hasPrefix("#") else { fatalError() }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        guard hexColor.count == 6 else { fatalError() }
        
        let scanner = Scanner(string: hexColor)
        
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { fatalError() }
        
        let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
        let b = CGFloat((hexNumber & 0x0000FF) >> 0) / 255
        
        self.init(displayP3Red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// Generate a dynamic color that changes according to the operating system dark/light mode
    /// - parameter light: color for light mode
    /// - parameter dark: color for dark mode
    /// - returns: dynamic color
    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {
                switch $0.userInterfaceStyle {
                case .dark: return dark
                default: return light
                }
            }
        } else {
            return light
        }
    }
}
