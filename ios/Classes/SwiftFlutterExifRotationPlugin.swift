import Flutter
import UIKit


public class SwiftFlutterExifRotationPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_exif_rotation", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterExifRotationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if (call.method == "rotateImage") {
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
            let imagePath = ((args as AnyObject)["path"]! as? String)!
            if let image = UIImage(contentsOfFile: imagePath), let updatedImage = image.fixImageToOrientationUp() {
                    let fileManager = FileManager.default
                    let imageData = updatedImage.jpegData(compressionQuality: 0.8)
                    fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)
                    result (imagePath);
            } else {
                result(imagePath)
            }
        }
    }
}
// Image extension
public extension UIImage {

    func fixImageToOrientationUp() -> UIImage? {
        switch self.imageOrientation {
        case .up:
            return self.setOrientation(orientation: .right).normalize()
        case .down:
            return self.setOrientation(orientation: .right).normalize()
        case .left:
            return self.setOrientation(orientation: .right).normalize()
        case .right:
            return self.normalize()
        default:
            return self
        }
    }
    
    func setOrientation(orientation: UIImage.Orientation) -> UIImage {
        if let cgImageData =  self.cgImage {
            return  UIImage(cgImage: cgImageData, scale: 1.0, orientation: orientation)
        } else {
            return self
        }
    }
    
    func normalize() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        
        return self
    }
}
