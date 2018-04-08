//
//  Services.swift
//  SwiftSyncPreviewer
//
//  Created by Lobanov Dmitry on 05.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
class Services {
    static let shared = Services()
    let changeService = MockChangeService()
    class func makeService(url: URL?, responder: SystemResponseWantsToSync?) -> ChangeService? {
        return FileChangeService().configured(url: url).configured(responder: responder)
    }
}

//Change Service
class ChangeService {
    var responder: SystemResponseWantsToSync?
    var url: URL?
    
    func start() {
        print("\(self) start service at url \(String(describing: self.url))")
    }
    
    func stop() {
        print("\(self) stop service at url \(String(describing: self.url))")
    }
}

//MARK: Convenient Run
extension ChangeService {
    func started() -> Self {
        self.start()
        return self
    }
    
    func stopped() -> Self {
        self.stop()
        return self
    }
}

//MARK: SystemRequestWantsToSync
extension ChangeService: SystemRequestWantsToSync {
    func wantsToSyncDocument(url: URL?) {
        self.url = url
        self.start()
    }
}

//MARK: Configuration
extension ChangeService {
    func configured(responder: SystemResponseWantsToSync?) -> Self {
        self.responder = responder
        return self
    }
    func configured(url: URL?) -> Self {
        self.url = url
        return self
    }
}

//Mock Service
class MockChangeService: ChangeService {
    var urls = [URL]()
    var timer: Timer?
    
    override init() {
        self.urls = [
            Bundle.main.url(forResource: "Sample", withExtension: "pdf"),
            Bundle.main.url(forResource: "Sample_1", withExtension: "pdf"),
            //            Bundle.main.url(forResource: "Sample_2", withExtension: "pdf")
            ].compactMap { $0 }
        super.init()
        self.start()
    }
    
    deinit {
        self.stop()
    }
    
    override func start() {
        self.setupTimer()
    }
    
    override func stop() {
        self.tearDownTimer()
    }

}

//MARK: Timer
extension MockChangeService {
    func setupTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MockChangeService.fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire() {
        // find url and take next.
        self.responder?.willSyncDocument(url: self.url)
        
        if let url = self.url {
            guard let index = self.urls.index(where: { _url in url.lastPathComponent == _url.lastPathComponent }) else {
                return
            }
            
            var theIndex = self.urls.index(after: index)
            if theIndex >= self.urls.endIndex {
                theIndex = 0
            }
            
            self.url = self.urls[theIndex]
        }
        
        guard let url = self.url else {
            return
        }
        
        self.responder?.didSyncDocument(result: .success(url))
    }
    
    func tearDownTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}

class FileChangeService: ChangeService {
    var witness: Witness?
    func shouldSync(flags: FileEventFlags) -> Bool {
        return flags.contains(FileEventFlags.ItemXattrMod) &&
        flags.contains(FileEventFlags.ItemIsFile)
    }
    override func start() {
        super.start()
        if let url = self.url {
            
            self.witness =
            Witness(paths: [url.path], flags: [.FileEvents], latency: 2) { (events) in
                print("received events at url: \(url). Events are: \(events)")
                for event in events {
                    if self.shouldSync(flags: event.flags) {
                        self.responder?.willSyncDocument(url: url)
                        self.responder?.didSyncDocument(result: .success(url))
                    }
                }
            }
        }
        else {
            self.stop()
        }
    }
    
    override func stop() {
        super.stop()
        self.witness?.flush()
    }
    
    deinit {
        self.stop()
    }
}
