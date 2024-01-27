//
//  QuoteService.swift
//  Musely
//
//  Created by Hardik Shukla on 1/27/24.
//

import UIKit
import Combine
// MARK: - QuoteServiceType Protocol
// Defines the contract for a service that fetches quotes.
protocol QuoteServiceType {
    func getRandomQuote()-> AnyPublisher<Quote, Error>
}

// MARK: - QuoteService
// Implementation of the QuoteServiceType, fetching quotes from an API.
class QuoteService: QuoteServiceType{
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        let url = URL(string: "https://api.quotable.io/random")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: Quote.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
}
