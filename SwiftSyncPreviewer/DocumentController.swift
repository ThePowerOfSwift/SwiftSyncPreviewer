//
//  DocumentController.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 06.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import Cocoa


class DocumentController: NSDocumentController {
    var closeWindowsTimer: Timer?
//    var closeWindowsTimer: Timer? = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DocumentController.fireTimer), userInfo: nil, repeats: true)
    override func beginOpenPanel(completionHandler: @escaping ([URL]?) -> Void) {
        super.beginOpenPanel(completionHandler: completionHandler)
    }
    override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
        super.beginOpenPanel(openPanel.singleFileOnly(), forTypes: inTypes, completionHandler: completionHandler)
    }
    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        return super.runModalOpenPanel(openPanel.singleFileOnly(), forTypes: types)
    }
    
    override init() {
        super.init()
//        self.closeWindowsTimer = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(DocumentController.fireTimer), userInfo: nil, repeats: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopTimer()
    }
}

extension DocumentController {
    @objc func fireTimer() {
        self.tryOpenChooseDocumentPanel()
    }
    func startTimer() {
    }
    func stopTimer() {
        self.closeWindowsTimer?.invalidate()
        self.closeWindowsTimer = nil
    }
}

extension NSOpenPanel {
    func singleFileOnly() -> Self {
        self.allowsMultipleSelection = false
        return self
    }
}

extension DocumentController: NSWindowDelegate {
    func openChooseDocumentPanel() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(300)) {
            self.openDocument(nil)
        }
    }
    func tryOpenChooseDocumentPanel() {
        if NSApp.windows.isEmpty {
            self.openChooseDocumentPanel()
        }
    }
    func windowWillClose(_ notification: Notification) {
        if NSApp.windows.count == 1 {
            self.openChooseDocumentPanel()
        }
    }
}
