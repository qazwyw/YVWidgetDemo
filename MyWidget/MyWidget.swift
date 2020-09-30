//
//  MyWidget.swift
//  MyWidget
//
//  Created by ImageMagic on 30/9/2020.
//

import WidgetKit
import SwiftUI
import AFNetworking

struct Provider: TimelineProvider {
    
//    /// 实现默认视图
//    func placeholder(in context: Context) -> PoetryEntry {
//        let poetry = Poetry(content: "床前明月光，疑似地上霜", origin: "耐依福", author: "佚名")
//        return PoetryEntry(date: Date(), poetry: poetry)
//    }
//
//    /// 在组件的添加页面可以看到效果
//    func getSnapshot(in context: Context, completion: @escaping (PoetryEntry) -> ()) {
//        let poetry = Poetry(content: "床前明月光，疑似地上霜", origin: "耐依福", author: "佚名")
//        let entry = PoetryEntry(date: Date(), poetry: poetry)
//        completion(entry)
//    }
    /// 实现默认视图
    func placeholder(in context: Context) -> ImageEntry {
        let image = ImageModel(url: "loaderror", copyright: "yvan", image: nil)
        return ImageEntry(date: Date(), image: image)
    }

    /// 在组件的添加页面可以看到效果
    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> ()) {
        let image = ImageModel(url: "loaderror", copyright: "yvan", image: nil)
        let imageEntry = ImageEntry(date: Date(), image: image)
        completion(imageEntry)
    }

    /// 在这个方法内可以进行网络请求，拿到的数据保存在对应的entry中，调用completion之后会到刷新小组件
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        // 下一次更新间隔以分钟为单位，间隔5分钟请求一次新的数据
        let updateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)
        ImageRequest.request { (result) in
            let image: ImageModel
            switch result {
            case .success(let response):
                image = response
                break;
            case .failure(_):
                image = ImageModel(url: "图片数据获取失败", copyright: "@yvan")
                break;
            }
            let entry = ImageEntry(date: updateDate!, image: image)
            let timeline = Timeline(entries: [entry], policy: .after(updateDate!))
            
            completion(timeline)
            
        }
//        PoetryRequest.request { result in
//            let poetry: Poetry
//            if case .success(let response) = result {
//                poetry = response
//            } else {
//                poetry = Poetry(content: "诗词加载失败，请稍微再试！", origin: "耐依福", author: "佚名")
//            }
//            let entry = PoetryEntry(date: updateDate!, poetry: poetry)
//            let timeline = Timeline(entries: [entry], policy: .after(updateDate!))
//            completion(timeline)
//        }
    }
}

struct PoetryRequest {
    static func request(completion: @escaping (Result<Poetry, Error>) -> Void) {
        let url = URL(string: "https://v1.alapi.cn/api/shici?type=all")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            let poetry = poetryFromJson(fromData: data!)
            completion(.success(poetry))
        }
        task.resume()
    }
    
    static func poetryFromJson(fromData data: Data) -> Poetry {
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        //因为免费接口请求频率问题，如果太频繁了，请求可能失败，这里做下处理，放置crash
        guard let data = json["data"] as? [String: Any] else {
            return Poetry(content: "诗词加载失败，请稍微再试！", origin: "耐依福", author: "佚名")
        }
        let content = data["content"] as! String
        let origin = data["origin"] as! String
        let author = data["author"] as! String
        return Poetry(content: content, origin: origin, author: author)
    }
}

struct Poetry {
    let content: String // 内容
    let origin: String // 名字
    let author: String // 作者
}

struct PoetryEntry: TimelineEntry {
    let date: Date
    let poetry: Poetry // 可以理解为绑定了Poetry模型数据
}

struct MyWidgetImageEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Image(uiImage: YVWidgetImageLoader.shareLoader.getImage(entry.image.url, UIImage()))
            .resizable()
            .scaledToFit()
            .cornerRadius(16)
            .frame(width: 44, height: 44)
    }
}

//struct MyWidgetEntryView : View {
//    var entry: Provider.Entry
//    @Environment(\.widgetFamily) var family
//
//    @ViewBuilder
//    var body: some View {
//        switch family {
//        case .systemSmall:
//            smallView(entry: entry)
//        case .systemMedium:
//            mediumView(entry: entry)
//        case .systemLarge:
//            Text("小组件-特大杯")
//        default:
//            Text("小组件-默认给个中杯的")
//        }
//    }
//}
//
//struct mediumView: View {
//    var entry: Provider.Entry
//    var body: some View {
//        HStack(alignment: .top, spacing: 0, content: {
//            Image("applogo")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            VStack(alignment: .leading, spacing: 4) {
//                Text(entry.poetry.origin)
//                    .font(.system(size: 20))
//                    .fontWeight(.bold)
//                Text(entry.poetry.author)
//                    .font(.system(size: 16))
//                Text(entry.poetry.content)
//                    .font(.system(size: 18))
//            }
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//            .padding()
//            .background(LinearGradient(gradient: Gradient(colors: [.init(red: 144 / 255.0, green: 252 / 255.0, blue: 231 / 255.0), .init(red: 50 / 204, green: 188 / 255.0, blue: 231 / 255.0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
//        })
//
//    }
//}
//
//
//struct smallView: View {
//    var entry: Provider.Entry
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(entry.poetry.origin)
//                .font(.system(size: 20))
//                .fontWeight(.bold)
//            Text(entry.poetry.author)
//                .font(.system(size: 16))
//            Text(entry.poetry.content)
//                .font(.system(size: 18))
//        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//        .padding()
//        .background(LinearGradient(gradient: Gradient(colors: [.init(red: 144 / 255.0, green: 252 / 255.0, blue: 231 / 255.0), .init(red: 50 / 204, green: 188 / 255.0, blue: 231 / 255.0)]), startPoint: .topLeading, endPoint: .bottomTrailing))
//    }
//}


@main
struct MyWidget: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            MyWidgetEntryView(entry: entry)
            MyWidgetImageEntryView(entry: entry)
        }
        .configurationDisplayName("阅文诗集")
        .description("Powed by yvan.")
    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetImageEntryView(entry: ImageEntry(date: Date(), image: ImageModel(url: "", copyright: "", image: UIImage()))).previewContext(WidgetPreviewContext(family: .systemSmall))
//        MyWidgetEntryView(entry: PoetryEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
