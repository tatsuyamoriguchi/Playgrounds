import UIKit

protocol APIRequest {
    associatedtype Response
    var urlRequest: URLRequest { get }
    func decodeResponse(data: Data) throws -> Response

    //func sendRequest<Request>(_ request: Request) async throws -> Request.Response where Request: APIRequest

//    func sendRequest<Request: APIRequest>(_ request: Request) async throws -> Request.Response
}



enum APIRequestError: Error {
    case itemNotFound
}

func sendRequest<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
    let (data, response) = try await URLSession.shared.data(for: request.urlRequest)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw APIRequestError.itemNotFound
    }
    
    let decodeResponse = try request.decodeResponse(data: data)
    return(decodeResponse)
}

struct PhotoInfo: Codable {
    var title: String
    var description: String
    var url: URL
    var copyright: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description = "explanation"
        case url
        case copyright
    }
}

struct PhotoInfoAPIRequest: APIRequest {
    
    var apiKey: String
    var urlRequest: URLRequest {
        var urlComponents = URLComponents(string: "https://api.nasa.gov/planetary/apod")!
        urlComponents.queryItems = [URLQueryItem(name: "date", value: "2021-07-15"), URLQueryItem(name: "api_key", value: apiKey)]
        return URLRequest(url: urlComponents.url!)
    }
    
    func decodeResponse(data: Data) throws -> PhotoInfo {
        let photoInfo = try JSONDecoder().decode(PhotoInfo.self, from: data)
        return photoInfo
    }
    
}

let photoInfoRequest = PhotoInfoAPIRequest(apiKey: "DEMO_KEY")
Task {
    do {
        let photoInfo = try await sendRequest(photoInfoRequest)
        print(photoInfo)
    } catch {
        print(error)
    }
}
