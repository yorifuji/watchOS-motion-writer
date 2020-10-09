//
//  ViewController.swift
//  watchOS-motion-writer
//
//  Created by yorifuji on 2020/10/06.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        else {
            print("WCSession not supported")
        }

    }


    @IBAction func onStart(_ sender: Any) {
        print(#function)
        send("start")
    }

    @IBAction func onStop(_ sender: Any) {
        print(#function)
        send("stop")
    }

    func send(_ command: String) {
        WCSession.default.sendMessage(["command" : command]) { reply in
            print(reply)
        } errorHandler: { error in
            print(error)
        }
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print(#function)
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print(#function)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
        replyHandler(["test":"ok"])
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print(file)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest = url.appendingPathComponent(file.fileURL.lastPathComponent)
        try! FileManager.default.copyItem(at: file.fileURL, to:dest)
        print(dest)
    }

//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        print(#function)
//        print(session)
//        print(activationState)
//    }
//
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print(#function)
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        print(#function)
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print(#function)
//        print(message)
//    }
}


