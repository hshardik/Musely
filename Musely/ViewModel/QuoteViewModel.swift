//
//  QuoteViewModel.swift
//  Musely
//
//  Created by Hardik Shukla on 1/27/24.
//

import UIKit
import Combine

// MARK: - QuoteViewModel
// ViewModel responsible for handling the business logic and state management.
class QuoteViewModel {
    
    // MARK: - Enums for Input and Output
    // Defines the types of input events the ViewModel can receive.
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
    }
    
    // Defines the types of output events the ViewModel can send to the View.
    enum Output {
        case fetchQuoteDidFail(error: Error)
        case fetchQuoteDidSucceed(quote: Quote)
        case toggleButton(isEnabled: Bool)
    }
    
    // MARK: - Properties
    private let quoteServiceType: QuoteServiceType // Dependency for fetching quotes.
    private let output: PassthroughSubject<Output, Never> = .init() // For publishing output events.
    private var cancellables =  Set<AnyCancellable>() // Stores subscriptions to avoid memory leaks.
    
    // MARK: - Initializer with Dependency Injection
    init(quoteServiceType: QuoteServiceType = QuoteService()) {
        self.quoteServiceType = quoteServiceType
    }
    
    // MARK: - Transform Method
    // Transforms input events into output events. Core of Combine's use in MVVM.
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { event in
            switch event {
            case .viewDidAppear, .refreshButtonDidTap:
                self.handleGetRandomQuote()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    // Handles fetching a random quote and publishing the result as an output event.
    private func handleGetRandomQuote() {
        output.send(.toggleButton(isEnabled: false)) // Disables button during fetch.
        quoteServiceType.getRandomQuote().sink { [weak self] completion in
            self?.output.send(.toggleButton(isEnabled: true)) // Re-enables button after fetch.
            if case .failure(let error) = completion {
                self?.output.send(.fetchQuoteDidFail(error: error))
            }
        } receiveValue: { [weak self] quote in
            self?.output.send(.fetchQuoteDidSucceed(quote: quote))
        }.store(in: &cancellables)
    }
}
