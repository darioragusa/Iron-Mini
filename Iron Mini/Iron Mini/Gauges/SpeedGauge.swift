//
//  SpeedGauge.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 24/09/22.
//

import SwiftUI

struct SpeedGauge: View {
    @Binding var speed: CGFloat
    @Binding var fuel: CGFloat
    @Binding var gaugeSpeed: CGFloat
    @Binding var gaugeFuel: CGFloat
    @State var fuelText = "0 L"
    
    private let lineWidth: CGFloat = 16
    @State var speedProgressColor: Color = Color(red: 128/255, green: 210/255, blue: 250/255)
    private let speedProgressBackgroundColor: Color = Color(red: 60/255, green: 100/255, blue: 120/255)
    @State var fuelProgressColor: Color = Color(red: 255/255, green: 255/255, blue: 255/255)
    private let fuelProgressBackgroundColor: Color = Color(red: 95/255, green: 115/255, blue: 130/255)
    private let backgroundColor: Color = Color(red: 35/255, green: 50/255, blue: 60/255)
    
    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                Circle()
                    .foregroundColor(backgroundColor)
                    .padding(.horizontal, lineWidth * 2)
                Gauge(trimValue: $gaugeSpeed,
                      trimTo: 0.75,
                      lineWidth: lineWidth,
                      padding: lineWidth * 3,
                      rotation: .degrees(-225),
                      strokeColor: $speedProgressColor,
                      backgroundStrokeColor: speedProgressBackgroundColor,
                      reversed: false)
                Gauge(trimValue: $gaugeFuel,
                      trimTo: 0.125,
                      lineWidth: lineWidth / 2,
                      padding: lineWidth,
                      rotation: .degrees(-252),
                      strokeColor: $fuelProgressColor,
                      backgroundStrokeColor: fuelProgressBackgroundColor,
                      reversed: false)
                VStack(spacing: 0) {
                    Text("\(Int(speed))")
                        .foregroundColor(.white)
                        .fontSizeFill(geometryReader.size, 0.25)
                        .padding(0)
                    Text("km/h")
                        .foregroundColor(.gray)
                        .fontSizeFill(geometryReader.size, 0.05)
                }
                GaugePerimeterText(size: geometryReader.size, text: .constant("F"), rotationDegrees: .degrees(108), keepOrientation: false)
                GaugePerimeterText(size: geometryReader.size, text: .constant("E"), rotationDegrees: .degrees(168), keepOrientation: false)
                GaugePerimeterText(size: geometryReader.size, text: $fuelText, rotationDegrees: .degrees(-140), keepOrientation: false)
                Image(systemName: "fuelpump.fill")
                    .fontSizeFill(geometryReader.size, 0.070)
                    .foregroundColor(.white)
                    .position(x: geometryReader.size.width * 0.1, y: geometryReader.size.height - ( geometryReader.size.height * 0.1))
            }
            .center(geometryReader.frame(in: .local))
        }
        .onChange(of: fuel, perform: { newValue in
            fuelProgressColor = newValue > 8 ? Color(red: 255/255, green: 255/255, blue: 255/255) : .red
            fuelText = "\(Int(newValue)) L"
        })
    }
}

struct SpeedGauge_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SpeedGauge(speed: .constant(5), fuel: .constant(48), gaugeSpeed: .constant(5 / 200 * 0.75), gaugeFuel: .constant(48 / 50 * 0.125))
        }
        .previewLayout(.fixed(width: 400, height: 400))
    }
}
