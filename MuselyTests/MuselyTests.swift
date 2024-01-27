//
//  MuselyTests.swift
//  MuselyTests
//
//  Created by Hardik Shukla on 1/27/24.
//

import XCTest
import Combine
@testable import Musely

class MuselyTests: XCTestCase {
    
    var sut: QuoteViewModel!
    var quoteService: MockQuoteServiceType!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        quoteService = MockQuoteServiceType()
        sut = QuoteViewModel(quoteServiceType: quoteService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        quoteService = nil
        cancellables = nil
        super.tearDown()
    }
    func testFetchQuoteSuccess() {
        // 1. Define expectations
        let expectedQuote = Quote(content: "Test Quote", author: "Test Author")
        let expectation = self.expectation(description: "Fetch quote succeeds and ViewModel outputs success event")
        quoteService.value = Just(expectedQuote).setFailureType(to: Error.self).eraseToAnyPublisher()
        
        // 2. Subscribe to the ViewModel's output
        let input = PassthroughSubject<QuoteViewModel.Input, Never>()
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                switch output {
                case .fetchQuoteDidSucceed(let quote):
                    XCTAssertEqual(quote.content, expectedQuote.content)
                    XCTAssertEqual(quote.author, expectedQuote.author)
                    expectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 3. Trigger input
        input.send(.viewDidAppear)
        
        // 4. Wait for expectations
        waitForExpectations(timeout: 1.0)
    }
    func testFetchQuoteFailure() {
        // 1. Define expectations
        let expectation = self.expectation(description: "Fetch quote fails and ViewModel outputs failure event")
        let testError = NSError(domain: "TestError", code: 0, userInfo: nil)
        quoteService.value = Fail(error: testError).eraseToAnyPublisher()
        
        // 2. Subscribe to the ViewModel's output
        let input = PassthroughSubject<QuoteViewModel.Input, Never>()
        sut.transform(input: input.eraseToAnyPublisher())
            .sink { output in
                switch output {
                case .fetchQuoteDidFail(let error):
                    XCTAssertEqual(error.localizedDescription, testError.localizedDescription)
                    expectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 3. Trigger input
        input.send(.refreshButtonDidTap)
        
        // 4. Wait for expectations
        waitForExpectations(timeout: 1.0)
    }
}


class MockQuoteServiceType: QuoteServiceType {
    var value: AnyPublisher<Quote, Error>?
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        return value ?? Empty().eraseToAnyPublisher()
    }
}
