//
//  MotionWriter.swift
//  CMHeadphoneMotionManager-Sampler
//
//  Created by yorifuji on 2020/10/03.
//

import Foundation
import CoreMotion

class MotionWriter {

    var file: FileHandle?
    var filePath: URL?
    var sample: Int = 0

    func open(_ filePath: URL) {
        do {
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            let file = try FileHandle(forWritingTo: filePath)
            var header = ""
            header += "acceleration_x,"
            header += "acceleration_y,"
            header += "acceleration_z,"
            header += "attitude_pitch,"
            header += "attitude_roll,"
            header += "attitude_yaw,"
            header += "gravity_x,"
            header += "gravity_y,"
            header += "gravity_z,"
            header += "quaternion_x,"
            header += "quaternion_y,"
            header += "quaternion_z,"
            header += "quaternion_w,"
            header += "rotation_x,"
            header += "rotation_y,"
            header += "rotation_z"
            header += "\n"
            file.write(header.data(using: .utf8)!)
            self.file = file
            self.filePath = filePath
        } catch let error {
            print(error)
        }
    }

    func write(_ motion: CMDeviceMotion) {
        guard let file = self.file else { return }
        var text = ""
        text += "\(motion.userAcceleration.x),"
        text += "\(motion.userAcceleration.y),"
        text += "\(motion.userAcceleration.z),"
        text += "\(motion.attitude.pitch),"
        text += "\(motion.attitude.roll),"
        text += "\(motion.attitude.yaw),"
        text += "\(motion.gravity.x),"
        text += "\(motion.gravity.y),"
        text += "\(motion.gravity.z),"
        text += "\(motion.attitude.quaternion.x),"
        text += "\(motion.attitude.quaternion.y),"
        text += "\(motion.attitude.quaternion.z),"
        text += "\(motion.attitude.quaternion.w),"
        text += "\(motion.rotationRate.x),"
        text += "\(motion.rotationRate.y),"
        text += "\(motion.rotationRate.z)"
        text += "\n"
        file.write(text.data(using: .utf8)!)
        sample += 1
    }

    func close() {
        guard let file = self.file else { return }
        file.closeFile()
        print("\(sample) sample")
        self.file = nil
    }

    static func getDocumentPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func makeFilePath() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: Date()) + ".csv"
        let fileUrl = url.appendingPathComponent(filename)
        print(fileUrl.absoluteURL)
        return fileUrl
    }
}


