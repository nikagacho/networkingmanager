
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case serverError(statusCode: Int)
    case decodingError
    case unknownError
}

@available(macOS 12.0, *)
@available(iOS 15.0, *)

public class NetworkManager<T: Codable> {
    public init() {}
    //URL + Auth Header
    public func fetchData(from urlString: String, headers: [String: String]) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
            
        } catch {
            throw error is NetworkError ? error : NetworkError.unknownError
        }
    }
    // URL Only
    public func fetchData(from urlString: String) async throws -> T {
           guard let url = URL(string: urlString) else {
               throw NetworkError.invalidURL
           }

           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               return try JSONDecoder().decode(T.self, from: data)
           } catch {
               throw NetworkError.requestFailed
           }
       }
    // Image
    func fetchImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw NetworkError.requestFailed
        }
    }

    
}
