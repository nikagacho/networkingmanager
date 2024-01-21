
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed
}

@available(iOS 15.0, *)
public class NetworkManager<T: Codable> {
    public init() {}

    public func fetchData(from urlString: String, headers: [String: String]) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.requestFailed
        }
    }
}

