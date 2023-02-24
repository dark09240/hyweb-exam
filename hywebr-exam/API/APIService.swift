//
//  APIService.swift
//  hywebr-exam
//
//  Created by Dong on 2023/2/22.
//

import Foundation

class APIService<T: Codable> {
    
    //MARK: - Typealias
    typealias APIServiceResult = (data: T?, errorType: ErrorType, errorMessage: String?)
    typealias CompletionHandler = (APIServiceResult)->()
    
    //MARK: - Enum
    enum ErrorType {
        case urlError
        case connection
        case server
        case dataError
        case noError
    }
    
    //MARK: - Variables
    private let timeout: TimeInterval = 3
    
    //MARK: - Actions
    func get(with urlString: String, completionHandler: @escaping CompletionHandler) {
        guard
            let percentURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: percentURLString)
        else {
            completionHandler((nil, .urlError, nil))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            guard error == nil else  {
                completionHandler((nil, .connection, error!.localizedDescription))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler((nil, .connection, "Response is nil."))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completionHandler((nil, .server, "HTTP status error(\(httpResponse.statusCode))."))
                return
            }
            
            guard let data else {
                completionHandler((nil, .dataError, "Data is nil."))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completionHandler((result, .noError, nil))
            }catch let decodeError {
                completionHandler((nil, .dataError, "JSON decode error(\(decodeError.localizedDescription))."))
            }
        }).resume()
    }
}
