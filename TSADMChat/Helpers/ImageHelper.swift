//
//  ImageHelper.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import Foundation
import PhotosUI
import CloudKit

/**
 # toCKAsset #
 A function that returns a CKAsset from a Data.
 
 - parameter data: The data to be converted to a CKAsset.
 - returns: A CKAsset with the data.
 */
extension Data{
    
    func toCKAsset()-> CKAsset?{
        do{
            guard let imagePNG = UIImage(data: self)?.pngData() else{
                return nil
            }
            guard let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat") else{
                return nil
            }
            try imagePNG.write(to: url)
            return CKAsset(fileURL:url)
        }catch{
            print(error)
        }
        
        return nil
    }
}

/**
 # toData #
 A function that returns a Data from a CKAsset.
 
 - parameter data: The CKAsset to be converted to a Data.
 - returns: A Data with the data from the CKAsset.
 */
extension CKAsset{
    
    func toData() -> Data?{
        do{
            if let url = fileURL{
                let data =  try NSData(contentsOf:url) as Data
                return data
            }
        }catch{
            print(error)
        }
        
        return nil
    }
}
