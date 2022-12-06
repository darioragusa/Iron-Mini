//
//  GaugeCircle.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 24/09/22.
//

import SwiftUI

struct GaugeCircle: View {
    @Binding var trimTo: CGFloat
    @Binding var trimValue: CGFloat
    @State var lineWidth: CGFloat
    @State var padding: CGFloat
    @Binding var rotation: Angle
    @Binding var strokeColor: Color
    @State var reversed: Bool
    
    var body: some View {
        Circle()
            .trim(from: 0, to: trimTo)
            .stroke(strokeColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    ))
            .rotationEffect(rotation + .degrees(CGFloat(reversed ? 360 : 0) * (trimValue - trimTo)))
            .padding(.horizontal, padding)
    }
}

struct GaugeCircle_Previews: PreviewProvider {
    static var previews: some View {
        GaugeCircle(trimTo: .constant(0.50), trimValue: .constant(1), lineWidth: 16, padding: 16, rotation: .constant(.degrees(-252)), strokeColor: .constant(.black), reversed: false)
    }
}
