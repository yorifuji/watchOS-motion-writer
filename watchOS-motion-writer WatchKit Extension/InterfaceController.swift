//
//  InterfaceController.swift
//  watchOS-motion-writer WatchKit Extension
//
//  Created by yorifuji on 2020/10/06.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity
import HealthKit


class InterfaceController: WKInterfaceController {

    var workoutSession: HKWorkoutSession?
    let motionManager = CMMotionManager()

    var writer: MotionWriter?

//    let healthStore = HKHealthStore()
//    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
//    let heartRateUnit = HKUnit(from: "count/min")
//    var heartRateQuery: HKQuery?

    @IBOutlet weak var button: WKInterfaceButton!

    @IBAction func onTapButton() {
        if self.workoutSession == nil {
            let config = HKWorkoutConfiguration()
            config.activityType = .other
            do {
                let healthStore = HKHealthStore()
                self.workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
                self.workoutSession?.delegate = self
                self.workoutSession?.startActivity(with: nil)
            }
            catch let e {
                print(e)
            }
        }
        else {
            self.workoutSession?.stopActivity(with: nil)
        }
    }


    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        else {
            print("WCSession not supported")
        }
    }
    
    override func willActivate() {
        print(#function)
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}

extension InterfaceController: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
        DispatchQueue.main.async {
            WCSession.default.sendMessage(["bpm": "test"], replyHandler: { reply in
                print(reply)
            } ) { error in
                print(error.localizedDescription)
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)

        let command: String = message["command"] as! String

        if command == "start" {
            DispatchQueue.main.async {
                self.startMotionWriter()
            }
        }
        else if command == "stop" {
            DispatchQueue.main.async {
                self.stopMotionWriter()
            }
        }

        replyHandler(["command":"ok"])
    }

}

extension InterfaceController: HKWorkoutSessionDelegate {

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print(#function)
        switch toState {
        case .running:
            print("Session status to running")
            self.startWorkout()
        case .stopped:
            print("Session status to stopped")
            self.stopWorkout()
            self.workoutSession?.end()
        case .ended:
            print("Session status to ended")
            self.workoutSession = nil
        default:
            print("Other status \(toState.rawValue)")
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workoutSession delegate didFailWithError \(error.localizedDescription)")
    }

    func startWorkout() {
        print(#function)
        DispatchQueue.main.async {
            self.button.setTitle("Stop")
        }
        startDeviceMotionUpdates()
    }

    func stopWorkout() {
        print(#function)
        DispatchQueue.main.async {
            self.button.setTitle("Start")
        }
        stopDeviceMotionUpdates()
    }
}

extension InterfaceController {
    func startDeviceMotionUpdates() {
        print(#function)
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let motion = motion {
                self.writeMotion(motion)
            }
        }
    }

    func stopDeviceMotionUpdates() {
        print(#function)
        motionManager.stopDeviceMotionUpdates()
    }
}

extension InterfaceController {
    func startMotionWriter() {
        print(#function)
        writer = MotionWriter()
        writer?.open(MotionWriter.makeFilePath())
    }

    func writeMotion(_ motion: CMDeviceMotion) {
        if let writer = self.writer {
            writer.write(motion)
        }
    }

    func stopMotionWriter() {
        print(#function)
        if let writer = self.writer {
            writer.close()
            if let filePath = writer.filePath {
                print(filePath)
                WCSession.default.transferFile(filePath, metadata: nil)
            }
            self.writer = nil
        }
    }

}

