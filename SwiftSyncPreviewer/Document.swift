//
//  Document.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Cocoa
import Quartz

class Document: NSDocument {
    
    var pdfDocument: PDFDocument?
    weak var responser: UserResponseWantsToSync?
    var service: SystemRequestWantsToSync?
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        self.service = Services.makeService(url: self.fileURL, responder: self)
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        
        // before add we should configure view controller.
        if let document = self.pdfDocument, let controller = windowController.contentViewController as? ViewController {
            _ = controller.configured(model: ViewController.Model().configured(document: self))
        }
        
        // set delegate?
        // document controller?
        windowController.window?.delegate = (NSApplication.shared.delegate as? AppDelegate)?.documentController
        self.addWindowController(windowController)
    }

//    override func data(ofType typeName: String) throws -> Data {
//        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
//        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//    }

//    override func read(from data: Data, ofType typeName: String) throws {
//        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
//        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
//        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        // check type?
        guard typeName == self.fileType else {
            self.pdfDocument = nil
            return
        }
        
        let document = PDFDocument(url: url)
        self.pdfDocument = document
        self.registerForSync()
    }
    
    override var isEntireFileLoaded: Bool {
        return self.pdfDocument != nil
    }
}

typealias VoidCompletion = (Result<Void, Error>) -> ()
//MARK: Read
extension Document {
    func read(from url: URL, response: VoidCompletion? ) {
        do {
            try self.read(from: url, ofType: self.fileType!)
            self.fileURL = url
            response?(.success(()))
        }
        catch let error {
            self.fileURL = nil
            response?(.error(error))
        }
    }
}

//MARK: Register for changes.
extension Document {
    func registerForSync() {
        self.service?.wantsToSyncDocument(url: self.fileURL)
    }
}

//MARK: SystemResponseWantsToSync
extension Document: SystemResponseWantsToSync {
    func willSyncDocument(url: URL?) {
        self.responser?.willSyncDocument(document: self)
    }
    
    func didSyncDocument(result: Result<URL, Error>) {
        switch result {
        case .success(let value):
            self.read(from: value) { (result) in
                switch result {
                case .success(_):
                    self.responser?.didSyncDocument(result: .success(self))
                case .error(let error):
                    self.responser?.didSyncDocument(result: .error(error))
                }
            }
        case .error(let error):
            self.responser?.didSyncDocument(result: .error(error))
        }
    }
}
