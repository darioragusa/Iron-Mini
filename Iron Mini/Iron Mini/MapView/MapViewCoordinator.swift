//
//  MapViewCoordinator.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 21/12/22.
//

import MapKit

class MapViewCoordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var mapViewController: MapView
        
    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            renderer.alpha = 0.8
            return renderer
        }
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapViewController.updateLocation(location: location)
            if let heading = manager.heading {
                mapViewController.updateHeading(heading: heading)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapViewController.updateHeading(heading: newHeading)
    }
}
