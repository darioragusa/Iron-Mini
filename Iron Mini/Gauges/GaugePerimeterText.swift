//
//  GaugePerimeterText.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 24/09/22.
//

import SwiftUI

struct GaugePerimeterText: View {
    @State var size: CGSize
    @Binding var text: String
    @State var rotationDegrees: Angle
    @State var keepOrientation: Bool
    @State var textSizes: [Int:Double] = [:]
    private var texts: [(offset: Int, element:Character)] {
        return Array(text.reversed().enumerated())
    }
    
    var body: some View {
        ZStack {
            ForEach (self.texts, id: \.self.offset) { (offset, element) in
                VStack {
                    Text(String(element))
                        .background(Sizeable())
                        .rotationEffect(keepOrientation ? rotationDegrees: .degrees(180))
                        .onPreferenceChange(WidthPreferenceKey.self,
                                            perform: { size in
                            self.textSizes[offset] = Double(size)
                        })
                    Spacer ()
                }
                .rotationEffect(self.angle(at: offset - 1, radius: size.width / 2))
            }
            .frame(width: size.width - 8, height: size.height - 8, alignment: .center)
            .fontSizeFill(size, 0.05)
            .rotationEffect((-self.angle(at: self.text.count - 1, radius: size.width / 2) / 2) - rotationDegrees)
            .foregroundColor(.white)
        }
    }
    
    private func angle(at index: Int, radius: Double) -> Angle {
        guard let labelSize = textSizes[index] else { return .radians(0) }
        let percentOfLabelInCircle = labelSize / radius.perimeter
        let labelAngle = 2 * Double.pi * percentOfLabelInCircle
        let totalSizeOfPreChars = textSizes.filter{$0.key < index}.map{$0.value}.reduce(0,+)
        let percenOfPreCharInCircle = totalSizeOfPreChars / radius.perimeter
        let angleForPreChars = 2 * Double.pi * percenOfPreCharInCircle
        return .radians(angleForPreChars + labelAngle)
    }
}

struct GaugePerimeterText_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            GaugePerimeterText(size: CGSize(width: 400, height: 400), text: .constant("A lot of text"), rotationDegrees: .degrees(135), keepOrientation: false)
            GaugePerimeterText(size: CGSize(width: 400, height: 400), text: .constant("👆🏻"), rotationDegrees: .degrees(-90), keepOrientation: true)
        }
        .previewLayout(.fixed(width: 400, height: 400))
    }
}

//Get size for label helper
struct WidthPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat(0)
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct Sizeable: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
        }
    }
}
