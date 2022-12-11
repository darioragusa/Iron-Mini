//
//  ContentView.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 18/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var kmh: CGFloat = 0
    @State var rpm: CGFloat = 0
    @State var coolant: CGFloat = 0
    @State var fuel: CGFloat = 0
    
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
            guard let message = messageReceived else { return }
            let receivedMessage = String(bytes: message, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if receivedMessage.isEmpty { return }
            print(receivedMessage)
            parseMessage(message: receivedMessage)
        })
        .onAppear(perform: {
            UIApplication.shared.isIdleTimerDisabled = true
        })
    }
    
    func parseMessage(message: String) {
        // 153=%d;316=%d;329=%d;613=%d
        for canData in message.split(separator: ";") {
            let canId = String(canData.split(separator: "=").first ?? "")
            let canValue = String(canData.split(separator: "=").last ?? "")
            let parsedCanVal = CGFloat(Int(canValue) ?? 0)
            switch (canId) {
            case "153":
                self.kmh = parsedCanVal
                self.gaugeSpeed = (self.kmh / self.maxSpeed * 0.75)
                break;
            case "316":
                self.rpm = parsedCanVal
                self.gaugeRpm = (self.rpm / self.maxRpm * 0.75)
                break;
            case "329":
                self.coolant = parsedCanVal
                self.gaugeCoolant = (self.coolant / self.maxCoolant * 0.125)
                break;
            case "613":
                self.fuel = parsedCanVal
                self.gaugeFuel = (self.fuel / self.fuelSize * 0.125)
                break;
            default:
                break;
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 812, height: 375)) // 1
            .environment(\.horizontalSizeClass, .compact) // 2
            .environment(\.verticalSizeClass, .compact) // 3
    }
}
