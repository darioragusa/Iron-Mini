//
//  RpmGauge.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 24/09/22.
//

import SwiftUI

struct RpmGauge: View {
    @Binding var rpm: UInt16
    @Binding var coolant: UInt8
    @Binding var gaugeRpm: CGFloat
    @Binding var gaugeCoolant: CGFloat
    @State var coolantText: String = "0 C °"
    
    private let lineWidth: CGFloat = 16
    @State var rpmProgressColor: Color = Color(red: 128/255, green: 210/255, blue: 250/255)
    private let rpmProgressBackgroundColor: Color = Color(red: 60/255, green: 100/255, blue: 120/255)
    @State var coolantProgressColor: Color = Color(red: 255/255, green: 255/255, blue: 255/255)
    private let coolantProgressBackgroundColor: Color = Color(red: 95/255, green: 115/255, blue: 130/255)
    private let backgroundColor: Color = Color(red: 35/255, green: 50/255, blue: 60/255)
    
    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                Circle()
                    .foregroundColor(backgroundColor)
                    .padding(.horizontal, lineWidth * 2)
                Gauge(trimValue: $gaugeRpm,
                      trimTo: 0.75,
                      lineWidth: lineWidth,
                      padding: lineWidth * 3,
                      rotation: .degrees(-225),
                      strokeColor: $rpmProgressColor,
                      backgroundStrokeColor: rpmProgressBackgroundColor,
                      reversed: false)
                Gauge(trimValue: $gaugeCoolant,
                      trimTo: 0.125,
                      lineWidth: lineWidth / 2,
                      padding: lineWidth,
                      rotation: .degrees(28),
                      strokeColor: $coolantProgressColor,
                      backgroundStrokeColor: coolantProgressBackgroundColor,
                      reversed: true)
                VStack(spacing: 0) {
                    Text(verbatim: "\(Int(rpm))")
                        .foregroundColor(.white)
                        .fontSizeFill(geometryReader.size, 0.20)
                        .padding(0)
                    Text("rpm")
                        .foregroundColor(.gray)
                        .fontSizeFill(geometryReader.size, 0.05)
                }
                GaugePerimeterText(size: geometryReader.size, text: .constant("🔥"), rotationDegrees: .degrees(-115), keepOrientation: true)
                GaugePerimeterText(size: geometryReader.size, text: .constant("❄️"), rotationDegrees: .degrees(-175), keepOrientation: true)
                GaugePerimeterText(size: geometryReader.size, text: $coolantText, rotationDegrees: .degrees(140), keepOrientation: false)
                Image(systemName: "thermometer")
                    .fontSizeFill(geometryReader.size, 0.070)
                    .foregroundColor(.white)
                    .position(x: geometryReader.size.width - (geometryReader.size.width * 0.1),
                              y: geometryReader.size.height - (geometryReader.size.height * 0.1))
            }
            .center(geometryReader.frame(in: .local))
        }
        .onChange(of: rpm, perform: { newValue in
            rpmProgressColor = newValue < 5500 ? Color(red: 128/255, green: 210/255, blue: 250/255) : .red
        })
        .onChange(of: coolant, perform: { newValue in
            coolantProgressColor = newValue < 95 ? Color(red: 255/255, green: 255/255, blue: 255/255) : .red
            coolantText = "\(Int(newValue)) C °"
        })
    }
}

struct RpmGauge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            RpmGauge(rpm: .constant(3000), coolant: .constant(90), gaugeRpm: .constant(3000 / 8000 * 0.75), gaugeCoolant: .constant(90 / 150 * 0.125))
        }
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
