//
//  Gauge.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 21/09/22.
//

import SwiftUI

struct Gauge: View {
    @Binding var trimValue: CGFloat
    @State var trimTo: CGFloat
    @State var lineWidth: CGFloat
    @State var padding: CGFloat
    @State var rotation: Angle
    @Binding var strokeColor: Color
    @State var backgroundStrokeColor: Color
    @State var reversed: Bool
    
    var body: some View {
        ZStack {
            GaugeCircle(trimTo: $trimTo,
                        trimValue: $trimValue,
                        lineWidth: lineWidth,
                        padding: padding,
                        rotation: $rotation,
                        strokeColor: $backgroundStrokeColor,
                        reversed: false)
            GaugeCircle(trimTo: $trimValue,
                        trimValue: $trimTo,
                        lineWidth: lineWidth,
                        padding: padding,
                        rotation: $rotation,
                        strokeColor: $strokeColor,
                        reversed: reversed)
            .animation(.easeOut, value: trimValue)
            //GaugeCircle(trimTo: $trimValue, lineWidth: lineWidth, padding: padding, rotation: $rotation + .degrees(CGFloat(reversed ? 360 : 0) * (trimTo - trimValue)), strokeColor: strokeColor)
        }
    }
    
    
}
struct Gauge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Gauge(trimValue: .constant(0.25), trimTo: 0.50, lineWidth: 16, padding: 16, rotation: .degrees(90), strokeColor: .constant(.gray), backgroundStrokeColor: .black, reversed: false)
            Gauge(trimValue: .constant(90 / 150 * 0.125), trimTo: 0.125, lineWidth: 8, padding: 16, rotation: .degrees(28), strokeColor: .constant(.gray), backgroundStrokeColor: .black, reversed: true)
        }
        .previewLayout(.fixed(width: 400, height: 400))
    }
}
