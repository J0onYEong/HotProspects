//
//  ImageSaver.swift
//  HotProspects
//
//  Created by 최준영 on 2023/02/06.
//
import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(inputImg: UIImage) {
        UIImageWriteToSavedPhotosAlbum(inputImg, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
