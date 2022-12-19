//
//  Extensions.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 22/09/22.
//

import SwiftUI


struct FontSizeFill: ViewModifier {
    var size: CGSize
    var modifier: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size.height > size.width ? (size.width * modifier): (size.height * modifier), design: .rounded))
    }
}

struct Center: ViewModifier {
    var frame: CGRect
    func body(content: Content) -> some View {
        content
            .position(x: frame.midX, y: frame.midY)
    }
}


extension View {
    func fontSizeFill(_ _size: CGSize, _ _modifier: CGFloat = 0.3) -> some View {
        modifier(FontSizeFill(size: _size, modifier: _modifier))
    }
    
    func center(_ _frame: CGRect) -> some View {
        modifier(Center(frame: _frame))
    }
}

extension Double {
    var perimeter: Double {
        return self * 2 * .pi
    }
}


//func reverseGaugeAngle(_ value: Binding<Angle>, reversed: Bool, trimTo: CGFloat, trimValue: CGFloat) -> Binding<Angle> {
//    let degreedDifference: Angle = .degrees(CGFloat(reversed ? 360 : 0) * (trimTo - trimValue))
//    let newAngle: Angle  = value.wrappedValue + degreedDifference
//    return Binding<Angle> (
//        get: { newAngle },
//        set: { _ in }
//    )
//}
