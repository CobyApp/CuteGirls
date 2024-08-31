//
//  UIImage+Assets.swift
//  CuteGirls
//
//  Created by Coby on 9/1/24.
//

import UIKit

extension UIImage {
    
    convenience init?(name: String) {
        self.init(named: name, in: .main, compatibleWith: nil)
    }
    
    static let icLogo = UIImage(name: "logo")!
    
    // Icon
    static let icCamera = UIImage(name: "camera")!
}

extension UIImage {
    var compressedImage: Data {
        self.jpegData(compressionQuality: 0.3)!
    }
}
