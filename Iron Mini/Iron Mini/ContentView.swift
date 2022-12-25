//
//  ContentView.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 18/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var kmh: UInt8 = 0
    @State var rpm: UInt16 = 0
    @State var coolant: UInt8 = 0
    @State var fuel: UInt8 = 0
    
    @State var gaugeSpeed: CGFloat = 0
    @State var gaugeFuel: CGFloat = 0
    @State var gaugeRpm: CGFloat = 0
    @State var gaugeCoolant: CGFloat = 0
    
    let maxSpeed: CGFloat = 200
    let fuelSize: CGFloat = 50
    let maxRpm: CGFloat = 8000
    let maxCoolant: CGFloat = 150
    
    @ObservedObject var udpListener: UDPListener = UDPListener(on: 16344)
    
    var body: some View {
        ZStack {
            Color.black
            MapView()
                .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black, .black]), startPoint: .bottomLeading, endPoint: .topTrailing))
                .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black, .black]), startPoint: .bottomTrailing, endPoint: .topLeading))
                .mask(LinearGradient(gradient: Gradient(colors: [.clear, .black, .black]), startPoint: .bottom, endPoint: .top))
            GeometryReader { geometryReader in
                VStack {
                    Spacer()
                    HStack {
                        SpeedGauge(speed: $kmh, fuel: $fuel, gaugeSpeed: $gaugeSpeed, gaugeFuel: $gaugeFuel)
                            .frame(width: geometryReader.size.width * 0.45, height: geometryReader.size.width * 0.45)
                        Spacer()
                        RpmGauge(rpm: $rpm, coolant: $coolant, gaugeRpm: $gaugeRpm, gaugeCoolant: $gaugeCoolant)
                            .frame(width: geometryReader.size.width * 0.45, height: geometryReader.size.width * 0.45)
                    }
                }
            }
        }
        .onReceive(udpListener.$messageReceived, perform: { messageReceived in
            if let message = messageReceived {
                print(message)
                parseMessage(message: message)
            }
        })
        .onAppear(perform: {
            UIApplication.shared.isIdleTimerDisabled = true
        })
    }
    
    func parseMessage(message: Data) {
        guard message.count == 5 else {
            return
        }
        
        let values = [UInt8](message)
        
        self.kmh = values[0];
        self.gaugeSpeed = CGFloat(self.kmh) / self.maxSpeed * 0.75
        
        self.rpm = UInt16(values[1]) + (UInt16(values[2]) << 8)
        self.gaugeRpm = CGFloat(self.rpm) / self.maxRpm * 0.75
        
        self.coolant = values[3]
        self.gaugeCoolant = CGFloat(self.coolant) / self.maxCoolant * 0.125
        
        self.fuel = values[4]
        self.gaugeFuel = CGFloat(self.fuel) / self.fuelSize * 0.125
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
