//
//  TileOverlay.swift
//  Iron Mini
//
//  Created by Dario Ragusa on 21/12/22.
//

import MapKit
import SQLite3


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

