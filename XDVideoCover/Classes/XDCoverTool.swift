//
//  XDCoverTool.swift
//  XDVideoCover
//
//  Created by dyw on 2023/2/24.
//

import Foundation
import AVFoundation

public class XDCoverModel {

    public var image: UIImage?
    
    public var requestTime: CMTime
    
    public init(image: UIImage? = nil, requestTime: CMTime) {
        self.image = image
        self.requestTime = requestTime
    }
}

public enum XDPlayState {
    case stopped
    case playing
    case paused
    case failed
}

public enum XDBuffState {
    case unknown
    case ready
    case delayed
}


public class XDCoverTool {
    
    public static func requestImage(from asset: AVAsset?, time: CMTime = .zero, closure: @escaping (UIImage?, CMTime)->()) {
        guard let asset = asset else {
            DispatchQueue.main.async {
                closure(nil, time)
            }
            return
        }
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            //如果不设置这两个属性为kCMTimeZero，则实际生成的图片和需要生成的图片会有时间差
            imageGenerator.requestedTimeToleranceBefore = CMTime.zero
            imageGenerator.requestedTimeToleranceAfter = CMTime.zero
            imageGenerator.appliesPreferredTrackTransform = true
            var actualTime: CMTime = CMTimeMake(value: 0, timescale: asset.duration.timescale)
            guard let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: &actualTime) else {
                DispatchQueue.main.async {
                    closure(nil, time)
                }
                return
            }
            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            DispatchQueue.main.async {
                closure(image, time)
            }
        }
    }
}

extension Double {
    
    /// 秒转成 00:00
    func secondMS() -> String {
        return String(format: "%02d:%02d", Int(self/60), Int(self)%60)
    }
    
}
