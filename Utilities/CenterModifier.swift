//
//  CenterModifier.swift
//  Utilities
//
//  Created by 小田島 直樹 on 2022/11/09.
//

import SwiftUI

public struct CenterModifier: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}
