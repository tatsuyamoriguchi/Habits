//
//  APIRequest.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

protocol APIRequest {
    associatedtype Response
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
}

extension APIRequest {
    var host: String { "localhost" }
//    var host: String { "127.0.0.1"}
    var port: Int { 8080 }
}
extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()

        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-type")
            request.httpMethod = "POST"
        }
        return request
    }
}

enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}

extension APIRequest where Response: Decodable {
    func send() async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIRequestError.itemsNotFound }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Response.self, from: data)
        
        return decoded
    }
}

// Update APIRequest with a new protocol extension specifically for fetching images.
// Replace import Foundation with import UIKit to use UIImage in your code.
// Add a new protocol extension with a new send(_:) method to handle images.
// Also degine a new error type to handle the cases of bad image data and missing image.
//
enum ImageRequestError: Error {
    case couldNotInitializeFromData
    case imageDataMissing
}

extension APIRequest where Response == UIImage {
    func send() async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw ImageRequestError.imageDataMissing }

        guard let image = UIImage(data: data) else {
            throw ImageRequestError.couldNotInitializeFromData
        }
        return image
    }
}

extension APIRequest {
    func send() async throws -> Void {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIRequestError.requestFailed }
    }
}
