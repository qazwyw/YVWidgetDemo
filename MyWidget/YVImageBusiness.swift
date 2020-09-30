//
//  YVImageBusiness.swift
//  TestWidget
//
//  Created by ImageMagic on 30/9/2020.
//

import WidgetKit
import Foundation
import UIKit

struct ImageRequest {
    static func request(completion: @escaping (Result<ImageModel, Error>) -> Void) {
        let url = URL(string: "https://v1.alapi.cn/api/acg?token=IcZLwsNPoKBbFTldSnB9&format=json")!
      
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            var poetry = imageFromJson(fromData: data!)
            YVWidgetImageLoader.shareLoader.downLoadImage(imageUrl: poetry.url) { (result) in
                switch result {
                case .success(let image):
                    poetry.image = image
                    
                    completion(.success(poetry))
                case .failure(let imageError):
                    poetry.image = nil
                    
                    completion(.failure(imageError))
                }
            }
//            completion(.success(poetry))
        }
        task.resume()
    }
    
    static func imageFromJson(fromData data: Data) -> ImageModel {
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        //因为免费接口请求频率问题，如果太频繁了，请求可能失败，这里做下处理，放置crash
        guard let data = json["data"] as? [String: Any] else {
            return ImageModel(url: "图片失败，请稍微再试！", copyright: "@yvan", image: nil)
        }
        let url = data["url"] as! String
//        let copyright = data["copyright"] as! String
        let copyright = "copyright"
        return ImageModel(url: url, copyright: copyright, image: nil)
    }
}

struct ImageModel {
    let url: String //     图片地址
    let copyright: String // 图片版权说明
    var image: UIImage?
}

struct ImageEntry: TimelineEntry {
    let date: Date
    let image: ImageModel // 可以理解为绑定了Poetry模型数据
}
