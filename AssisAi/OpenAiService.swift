//
//  OpenAiService.swift
//  AssisAi
//
//  Created by Abdelrahman Moustafa on 18/03/2023.
//

import Foundation
import Alamofire
import Combine
class OpenAiService {
    let baseUrl = "https://api.openai.com/v1/"
    
    func sendMessage(message: String) -> AnyPublisher<OpenAiCompleteionResponse, Error>{
        let body = completionsBody(model: "text-davinci-003", prompt: message, temperature: 0.3, max_tokens: 256)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAiApiKey)"
        ]
        
        return Future {[weak self] promise in
            guard let self = self else {return}
            AF.request(self.baseUrl + "completions", method: .post, parameters: body, encoder: .json, headers: headers ).responseDecodable(of: OpenAiCompleteionResponse.self) { response in
                switch response.result {
                case .success(let result):
                    promise(.success(result))
                    
                case .failure(let error):
                    promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
}

struct completionsBody: Encodable {
    let model: String
    let prompt: String
    let temperature: Float?
    let max_tokens: Int
}
struct OpenAiCompleteionResponse: Decodable {
    let id: String
    let choices: [OpenAiCompleteionChoices]
}

struct OpenAiCompleteionChoices: Decodable {
    let text: String
    
}
