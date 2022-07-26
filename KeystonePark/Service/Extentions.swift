//
//  Extentions.swift
//  KeystonePark
//
//  Created by Apple on 26.07.2022.
//

import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
}
