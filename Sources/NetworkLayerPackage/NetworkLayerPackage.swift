
import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
}

@available(iOS 15.0, *)
class NetworkManager<T: Codable> {
    func fetchData(from urlString: String) async throws -> T {
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
}

