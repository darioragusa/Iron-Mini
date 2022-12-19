import Cocoa
import Foundation
import SQLite3

// https://stackoverflow.com/questions/5613898/storing-images-in-sql-server

let tilesPath = URL(string: "/Users/darioragusa/Downloads/maps/17")!
let dbPath = "/Users/darioragusa/Downloads/maps/Tiles.db"
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

let createTableString = """
CREATE TABLE tiles(
x INT NOT NULL,
y INT NOT NULL,
tile BLOB,
PRIMARY KEY (x, y));
"""
let insertStatementString = "INSERT INTO tiles (x, y, tile) VALUES (?, ?, ?);"

var db: OpaquePointer?
if sqlite3_open(dbPath, &db) == SQLITE_OK {
    print("Successfully opened connection to database at \(dbPath)")
} else {
    print("Unable to open database.")
}

var createTableStatement: OpaquePointer?
if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
    if sqlite3_step(createTableStatement) == SQLITE_DONE {
        print("\nContact table created.")
    } else {
        print("\nContact table is not created.")
    }
} else {
    print("\nCREATE TABLE statement is not prepared.")
}
sqlite3_finalize(createTableStatement)
    
let xFolders = FileManager().contentsOfDirectory(at: tilesPath, includingPropertiesForKeys: [], options: .skipsHiddenFiles).sorted { // Skipping hidden files because macOS adds .DS_Store
    $0.lastPathComponent < $1.lastPathComponent
}
for xFolder in xFolders {
    let yTiles = FileManager().contentsOfDirectory(at: xFolder, includingPropertiesForKeys: [], options: .skipsHiddenFiles).sorted { // Skipping hidden files because macOS adds .DS_Store
        $0.lastPathComponent < $1.lastPathComponent
    }
    for yTile in yTiles {
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            let x: Int32 = Int32(xFolder.lastPathComponent) ?? 0
            let y: Int32 = Int32(yTile.lastPathComponent.split(separator: ".").first ?? "0") ?? 0
            let blob: NSData = NSData(contentsOf: yTile)
            sqlite3_bind_int(insertStatement, 1, x)
            sqlite3_bind_int(insertStatement, 2, y)
            sqlite3_bind_blob(insertStatement, 3, blob.bytes, Int32(blob.length), SQLITE_TRANSIENT)
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("\nCould not insert row. (x: \(x), y: \(y))")
            }
        } else {
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
}
print("\nDONE!")
