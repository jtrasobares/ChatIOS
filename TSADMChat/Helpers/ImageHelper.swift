//
//  ImageHelper.swift
//  TSADMChat
//
//  Created by Jose Ignacio Trasobares Ibor on 12/2/24.
//

import Foundation
import PhotosUI
import CloudKit

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
