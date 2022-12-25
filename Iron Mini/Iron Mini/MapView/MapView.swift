//
//  MapView.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 09/12/22.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let mapView = MKMapView(frame: .zero)
    let locationManager = CLLocationManager()

    func makeUIView(context: Context) -> MKMapView {
        let layer = TileOverlay()
        layer.minimumZ = 17
        layer.maximumZ = 17
        layer.canReplaceMapContent = true
        mapView.addOverlay(layer)
        
        mapView.isUserInteractionEnabled = false
        mapView.showsScale = false
        mapView.showsCompass = true

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context){
        view.delegate = context.coordinator
        
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        view.showsUserLocation = true
    }
    
    func makeCoordinator() -> MapViewCoordinator{
         MapViewCoordinator(self)
    }
    
    func updateLocation(location: CLLocation) {
        let userCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let mapCamera = MKMapCamera(lookingAtCenter: userCoordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 750.0)
        mapView.setCamera(mapCamera, animated: true)
    }
    
    func updateHeading(heading: CLHeading) {
        mapView.camera.heading = heading.trueHeading - 90
        mapView.setCamera(mapView.camera, animated: true)
    }
}
