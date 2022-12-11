//
//  MapView.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 09/12/22.
//

import SwiftUI
import MapKit
import SQLite3

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
        // 36.85907496926761, 14.760897966396922
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

class TileOverlay: MKTileOverlay {
    let dbPath = Bundle.main.url(forResource: "Tiles", withExtension: "db")!.path
    var db: OpaquePointer?
    
    override init(urlTemplate URLTemplate: String?) {
        super.init(urlTemplate: URLTemplate)
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            print("Unable to open database.")
        }
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void){
        let queryStatementString = "SELECT tile FROM tiles WHERE x = \(path.x) AND y = \(path.y);"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                if let tileBlob = sqlite3_column_blob(queryStatement, 0){
                    let tileBlobLength = sqlite3_column_bytes(queryStatement, 0)
                    let tile = Data(bytes: tileBlob, count: Int(tileBlobLength))
                    result(tile, nil)
                }
            } else {
                print("\nQuery returned no results.")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\nQuery is not prepared \(errorMessage)")
        }
        sqlite3_finalize(queryStatement)
            
    }
}
