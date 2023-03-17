#if os(iOS)
import UIKit
import Foundation
#elseif os(macOS)
import AppKit
#endif

/**
 
 About Corner Radius
 https://stackoverflow.com/questions/2105289/iphone-app-icons-exact-radius
 
 corner radius for the 512x512 icon = 80 (iTunesArtwork)
 corner radius for the 1024x1024 icon = 180 (iTunesArtwork Retina)
 corner radius for the 57x57 icon = 9 (iPhone/iPod Touch)
 corner radius for the 114x114 icon = 18 (iPhone/iPod Touch Retina)
 corner radius for the 72x72 icon = 11 (iPad)
 corner radius for the 144x144 icon = 23 (iPad Retina)
 
 OR
 
 10/57 x {new size}
 
 OR
 
 22.37% is the key percentage here. Multiply any of the image sizes mentioned above in by 0.2237 and you will get the correct pixel radius for that size.
 
 */

public struct AppIconGen {
#if os(iOS)
    public static func generateIconImageFromXib (name: String) {
        let appIconView = Bundle.main.loadNibNamed(name, owner: nil)?[0] as! UIView
        let image = appIconView.asImage(rect: appIconView.bounds)!
        self.savePng(image)
    }
    
    public static func generateIconImageFromXib (name: String, cornerRadius: Float) {
        let appIconView = Bundle.main.loadNibNamed(name, owner: nil)?[0] as! UIView
        let layer = appIconView.layer
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.masksToBounds = true
        let image = appIconView.asImage(rect: appIconView.bounds)!
        self.savePng(image)
    }
    
    static func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return path.first
    }
    
    public static func savePng(_ image: UIImage) {
        let fileName = UUID().uuidString
        if let pngData = image.pngData(),
            let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).png") {
            try? pngData.write(to: path)
            print("image write to \(path)")
        }
    }
    
    public static func saveJpg(_ image: UIImage) {
        let fileName = UUID().uuidString
        if let jpgData = image.jpegData(compressionQuality: 0.5),
            let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).jpg") {
            try? jpgData.write(to: path)
            print("image write to \(path)")
        }
    }
    
#elseif os(macOS)
    public static func generateIconImageFromXib (name: String) {
        var topLevelArray: NSArray? = nil
        Bundle.main.loadNibNamed(name, owner: nil, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray as? [Any],
              results.count > 0,
              let firstView = results.first(where: {$0 is NSView}),
              let appIconView = firstView as? NSView
        else { return }
        guard let image = appIconView.asImage(rect: appIconView.bounds) else { return }
        self.savePng(image)
    }
    
    public static func generateIconImageFromXib (name: String, cornerRadius: Float) {
        var topLevelArray: NSArray? = nil
        Bundle.main.loadNibNamed(name, owner: nil, topLevelObjects: &topLevelArray)
        guard let results = topLevelArray as? [Any],
              results.count > 0,
              let firstView = results.first(where: {$0 is NSView}),
              let appIconView = firstView as? NSView
        else { return }
        
        appIconView.wantsLayer = true
        if let layer = appIconView.layer {
            layer.cornerRadius = CGFloat(cornerRadius)
            layer.masksToBounds = true
        }
        
        guard let image = appIconView.asImage(rect: appIconView.bounds) else { return }
        self.savePng(image)
    }
    
    static func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return path.first
    }
    
    public static func savePng(_ image: NSImage) {
        let fileName = UUID().uuidString
        if let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).png") {
            let result = image.pngWrite(to: path)
            print("\(result ? "[Success]" : "[Fail]")image write to \(path)")
        }
    }
    
    public static func saveJpg(_ image: NSImage) {
        let fileName = UUID().uuidString
        if let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).png") {
            let result = image.jpgWrite(to: path)
            print("\(result ? "[Success]" : "[Fail]")image write to \(path)")
        }
    }
#endif
}

#if os(iOS)
extension UIView {
    public func asImage(rect: CGRect) -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: rect)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            // Fallback on earlier versions
            return nil
        }
    }
}

#elseif os(macOS)

extension NSView {
    public func asImage(rect: CGRect) -> NSImage? {
        let mySize = self.bounds.size;
        let imgSize = NSMakeSize( mySize.width, mySize.height );
        
        guard let bir = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
            return nil
        }
        bir.size = imgSize
        self.cacheDisplay(in: self.bounds, to: bir)
        
        let image = NSImage(size: imgSize)
        image.addRepresentation(bir)
        return image
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func jpgData() -> Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.5])
    }
    
    func jpgWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try jpgData()?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
#endif
