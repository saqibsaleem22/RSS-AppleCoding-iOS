//
//  Extension.swift
//  LectorNoticias
//
//  Created by saqib on 29/08/2019.
//  Copyright © 2019 saqib. All rights reserved.
//
import UIKit

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension UIImage {
    func resize(width:CGFloat) -> UIImage? {
        let scale = width / self.size.width
        let height = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
