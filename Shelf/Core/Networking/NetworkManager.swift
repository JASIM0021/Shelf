//
//  NetworkManager.swift
//  Shelf
//
//  Created by Sk Jasimuddin on 30/04/25.
//

import Foundation
import Alamofire


enum HeaderType {
  case withUUID
  case withoutUUID
  case emptyHeaders
}

class NetworkingManager {

  // Singleton instance
  static let shared = NetworkingManager()
  private init() {}

  func request<T: Decodable>(
    directURL:String = "",
    endpoint: APIEndPoint,
    parameters: Parameters? = nil,
    headers: HTTPHeaders? = nil,
    headerType: HeaderType = .withUUID ,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    var headers: HTTPHeaders
    switch headerType {
    case .withUUID:
      headers = [
        "Content-Type": "application/json",
//        "Authorization": "BEARER " + "\(CustomAppStorage.get("token", defaultValue: ""))",
//        "Uuid": CustomAppStorage.get("uuid", defaultValue: ""),
//        "user-agent":"ios",
//        "origin": ""
      ]
    case .withoutUUID:
      headers = [
        "Content-Type": "application/json",
//        "origin": ""
      ]
    case .emptyHeaders:
        headers = [
          "Content-Type": "application/json",
        ]
    }
//    if directURL != "" {
//
//
//      if headers.isEmpty {
//        headers = [:]
//      }
//      else{
//
//      }
//      headers["origin"] = paybittoOrigin
//
//    }
    print("#Api requesting....\(endpoint.urlPath)")
    print("#Api directURL....\(directURL)")
    print("#method --> \(endpoint.method)")
    print("#parameter --> \(parameters)")
    print("#header --> \(headers)")
    AF.request(directURL != "" ? directURL : endpoint.urlPath, method: endpoint.method, parameters: parameters,encoding: endpoint.method == .post ? JSONEncoding.default : URLEncoding.default, headers:  headers)
      .validate()
      .responseDecodable(of: T.self) { response in
        if let data = String(data: response.data ?? Data(), encoding: .utf8) {
          print("Response: \(data)")
        }
        if let statusCode = response.response?.statusCode {
          if statusCode == 401 {
//            CustomAppStorage.delete("token")
            DispatchQueue.main.async {
//                CustomAppStorage.logout()
//              self.isLoggedIn = false
                }
          }
        }
        self.handleResponse(response, completion: completion)
      }
  }
  /// Handle the response and decode the data.
  private func handleResponse<T: Decodable>(
    _ response: AFDataResponse<T>,
    completion: (Result<T, Error>) -> Void
  ) {
    switch response.result {
    case .success(let value):
      completion(.success(value))
    case .failure(let error):
      completion(.failure(error))
    }
  }

}

