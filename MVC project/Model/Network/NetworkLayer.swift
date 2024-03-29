//
//  NetworkLayer.swift
//  homework4.4
//
//  Created by Zhansuluu Kydyrova on 4/1/23.
//

import UIKit
import Foundation
import RxSwift
import Alamofire

final class NetworkLayer {
    
    static let shared = NetworkLayer()
    private init() { }
    
    var baseURL = URL(string: "https://dummyjson.com/products")!
    let session = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask? = nil
    
    func decodeOrderTypeData(_ json: String) -> [OrderTypeModel] {
        var orderTypeModelArray = [OrderTypeModel]()
        let orderTypeData = Data(json.utf8)
        do {
            let orderTypeModelData = try JSONDecoder().decode([OrderTypeModel].self, from: orderTypeData)
            orderTypeModelArray = orderTypeModelData
        } catch {
            print(error.localizedDescription)
        }
        return orderTypeModelArray
        
    }
        
    func decodeData<T: Decodable>(data: Data) async throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
//         find async await
    
    func fetchProductsData() -> Observable<[ProductModel]> {
        return Observable<[ProductModel]>.create { observer in
            let task = URLSession.shared.dataTask(with: self.baseURL) { data, _, _ in
                
                do {
                    guard let data = data else { return }
                    let model = try JSONDecoder().decode(MainProductModel.self, from: data)
                    observer.onNext(model.products)
                } catch {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
            
        }
        
    }
    
//                        delete to async await
    
    func deleteProductsData(id: Int) async throws -> ProductModel {
        
        var request = URLRequest(url: baseURL.appendingPathComponent("\(id)"))
            request.httpMethod = "DELETE"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try await decodeData(data: data)
    }
    
    
    func decodeData<T: Decodable>(data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    func encodeData<T: Encodable>(product: T, completion: @escaping (Result<Data, Error>) -> Void) {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(product)
            completion(.success(encodedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func initializeData<T: Encodable>(product: T) -> Data? {
        var encodedData: Data?
        encodeData(product: product) { result in
            switch result {
            case .success(let model):
                encodedData = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return encodedData
    }
    
}

