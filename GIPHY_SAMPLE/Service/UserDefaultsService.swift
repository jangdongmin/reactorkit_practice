//
//  UserDefaultsService.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import Foundation
import RxSwift

class UserDefaultsService {
    static func set(value: [String : GifObject], forKey key: String) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            var saveData = [String : String]()
            for (key, value) in value {
                let JSONString = value.toJSONString(prettyPrint: true)
                saveData[key] = JSONString
            }
            
            UserDefaults.standard.set(object: saveData, forKey: key)
            UserDefaults.standard.synchronize()
             
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    static func value(forKey key: String) -> Observable<([String : GifObject]?)> {
        guard let loadData = UserDefaults.standard.object([String: String].self, with: key) else {
            return .just(nil)
        }
        
        return Observable.create { observer -> Disposable in
            var saveData = [String : GifObject]()
            for (key, value) in loadData {
                saveData[key] = GifObject(JSONString: value)
            }
            
            observer.onNext(saveData)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    static func value(forKey key: String) -> [String : GifObject]? {
        guard let loadData = UserDefaults.standard.object([String: String].self, with: key) else {
            return nil
        }
        
        var saveData = [String : GifObject]()
        for (key, value) in loadData {
            saveData[key] = GifObject(JSONString: value)
        }
        
        return saveData
    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}
