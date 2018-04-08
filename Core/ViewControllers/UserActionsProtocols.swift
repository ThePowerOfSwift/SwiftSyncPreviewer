//
//  UserActionsProtocols.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

protocol UserResponseWantsToSync: class {
    func willSyncDocument(document: Document)
    func didSyncDocument(result: Result<Document, Error>)
}

protocol SystemRequestWantsToSync: class {
    func wantsToSyncDocument(url: URL?)
}

protocol SystemResponseWantsToSync: class {
    func willSyncDocument(url: URL?)
    func didSyncDocument(result: Result<URL, Error>)
}
