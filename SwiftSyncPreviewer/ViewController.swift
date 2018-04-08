//
//  ViewController.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Cocoa
import Quartz
struct FunctionLimit: Hashable {
    var name: String
    var label: String
}

class __PDFView: PDFView {
    // reactive class.
    override func draw(_ page: PDFPage, to context: CGContext) {
        //        drawPageCalled += 1
        //        if drawPageCalled > 1 {
        //            cleanupView()
        //            drawPageCalled = 0
        //            return
        //        }
        // reset dictionary if page is not the same.
        //        if page.label != functionsLimitLabel {
        //            functionsLimit[#function] = 0
        //            functionsLimitLabel = page.label
        //        }
        
//        let tuple = FunctionLimit(name: #function, label: page.label!)
//        if functionsLimit[tuple] != 0 {
//            functionsLimit[tuple] = 0
//            return
//        }
//
//        functionsLimit[tuple] = 1
//        Swift.print("page: \(String(describing: page.label)): \(#function): \(String(describing: functionsLimit[tuple]))")
        super.draw(page, to: context)
    }
    
    override func drawPagePost(_ page: PDFPage, to context: CGContext) {
//        let tuple = FunctionLimit(name: #function, label: page.label!)
//
//        if functionsLimit[tuple] != 0 {
//            functionsLimit[tuple] = 0
//            return
//        }
//
//        functionsLimit[tuple] = 1
//        Swift.print("page: \(String(describing: page.label)): \(#function): \(String(describing: functionsLimit[tuple]))")
        super.drawPagePost(page, to: context)
    }
}
class _PDFView: PDFView {
    var drawPageCalled = 0
    var functionsLimit = [FunctionLimit : Int]()
    var functionsLimitLabel: String?
    func cleanupView() {
//        let selector = Selector("clipView")
//        let result = self.perform(selector)
        DispatchQueue.main.async {
            let views = self.subviews
            Swift.print("\(views)")
        }
//        (result as? NSView)?.removeFromSuperview()
    }
//    override func draw(_ dirtyRect: NSRect) {
//        //nothing?
//    }
    override func draw(_ page: PDFPage, to context: CGContext) {
//        drawPageCalled += 1
//        if drawPageCalled > 1 {
//            cleanupView()
//            drawPageCalled = 0
//            return
//        }
        drawPageCalled += 1
        // reset dictionary if page is not the same.
//        if page.label != functionsLimitLabel {
//            functionsLimit[#function] = 0
//            functionsLimitLabel = page.label
//        }
        
        let tuple = FunctionLimit(name: #function, label: page.label!)
        if (functionsLimit[tuple] ?? 0) == 0 || (functionsLimit[tuple] ?? 0) > 2 {
//            super.draw(page, to: context)
//            super.draw(page, to: context)
            functionsLimit[tuple] = 1
            return
        }

        functionsLimit[tuple] = (functionsLimit[tuple] ?? 0) + 1
        Swift.print("page: \(String(describing: page.label)): \(#function): \(String(describing: functionsLimit[tuple]))")
        Swift.print("called: \(drawPageCalled)")
        super.draw(page, to: context)
        super.draw(page, to: context)
    }
    
    override func drawPagePost(_ page: PDFPage, to context: CGContext) {
        let tuple = FunctionLimit(name: #function, label: page.label!)

        if functionsLimit[tuple] != 0 {
            super.drawPagePost(page, to: context)
            super.drawPagePost(page, to: context)
            functionsLimit[tuple] = 0
            return
        }

        functionsLimit[tuple] = 1
        Swift.print("page: \(String(describing: page.label)): \(#function): \(String(describing: functionsLimit[tuple]))")
        super.drawPagePost(page, to: context)
        super.drawPagePost(page, to: context)
    }
}

class ViewController: NSViewController {

    class Model {
        var document: Document?
    }
    
    var model: Model?
    @IBOutlet weak var pdfView: PDFView?
    
    // retrieve document.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.            
        }
    }
}

//MARK: Model
extension ViewController: HasModelProtocol {
    typealias ModelType = Model
    func updateForNewModel() {
        // nothing here?
        // or render something?
        self.model?.document?.responser = self
        self.fillView()
    }
}

extension NSView {
    func inspectSubviewsLevel(_ level: Int = 1) -> [CustomDebugStringConvertible] {
        if level == 0 {
            return ["\(level) -> \(self)"]
        }
        else {
            return ["\(level): \(self)"] + self.subviews.map {$0.inspectSubviewsLevel(level - 1)}
        }
    }
}

//MARK: Setup
extension ViewController {
    func setupUI() {
        setupView()
    }
    
    func setupView() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.PDFViewPageChanged, object: self.pdfView, queue: nil) { (notification) in
//            print("notification: \(notification)")
//            print("pdfView: \(String(describing: self.pdfView?.inspectSubviewsLevel(3)))")
        }
        
        self.pdfView?.displayMode = .singlePage
        self.pdfView?.autoScales = true
        self.pdfView?.backgroundColor = NSColor.lightGray
    }
}

//MARK: Fill document.
extension ViewController {
    func fillView() {
        guard let document = self.model?.document else {
            return
        }
        
        guard let pdf = document.pdfDocument else {
            return
        }
        self.pdfView?.document = pdf
    }
}

//MARK: UserResponseRefreshedDocument
extension ViewController: UserResponseWantsToSync {
    func willSyncDocument(document: Document) {
        // prepare for syncing
    }
    
    func didSyncDocument(result: Result<Document, Error>) {
        switch result {
        case .success(let document):
            // render
            print("change to document: \(String(describing: document.fileURL))")
            self.fillView()
            return
        case .error(let error):
            // show error
            self.presentError(error)
            return
        }
    }
}

