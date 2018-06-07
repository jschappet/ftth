//
//  CouchdbClient.swift
//  ftth
//
//  Created by Schappet, James C on 6/6/18.
//  Copyright © 2018 Schappet.com. All rights reserved.
//

import Foundation
import SwiftCloudant
class MyDbClient {

// Create a CouchDBClient
let cloudantURL = URL(string:"https://data.schappet.com")!
let client = CouchDBClient(url:URL(string:"https://data.schappet.com")!, username:"schappetj", password:"XXXXXXXX")
let dbName = "sample_db"

func createDocument() {
// Create a document
    let create = PutDocumentOperation(id: "doc1", body: ["hello":"world"], databaseName: dbName) {(response, httpInfo, error) in
        if let error = error {
            print("Encountered an error while creating a document. Error:\(error)")
        } else {
            print("Created document \(response?["id"] ?? "NA") with revision id \(response?["rev"] ?? "NA")")
        }
    }
    client.add(operation:create)
}

/*
// create an attachment
let attachment = "This is my awesome essay attachment for my document"
let putAttachment = PutAttachmentOperation(name: "myAwesomeAttachment",
                                           contentType:"text/plain",
                                           data: attachment.data(using: String.Encoding.utf8, allowLossyConversion: false)!,
                                           documentID: "doc1",
    revision: "1-revisionidhere",
    databaseName: dbName) { (response, info, error) in
        if let error = error {
            print("Encountered an error while creating an attachment. Error:\(error)")
        } else {
            print("Created attachment \(response?["id"] ?? "NA") with revision id \(response?["rev"] ?? "NA")")
        }
}
client.add(operation: putAttachment)

// Read a document
let read = GetDocumentOperation(id: "doc1", databaseName: dbName) { (response, httpInfo, error) in
    if let error = error {
        print("Encountered an error while reading a document. Error:\(error)")
    } else {
        print("Read document: \(response ?? )")
    }
}
client.add(operation:read)

// Delete a document
let delete = DeleteDocumentOperation(id: "doc1",
                                     revision: "1-revisionidhere",
                                     databaseName: dbName) { (response, httpInfo, error) in
                                        if let error = error {
                                            print("Encountered an error while deleting a document. Error: \(error)")
                                        } else {
                                            print("Document deleted")
                                        }
}
client.add(operation:delete)
*/

}
