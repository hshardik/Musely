//
//  QuoteViewController.swift
//  Musely
//
//  Created by Hardik Shukla on 1/27/24.
//

import UIKit
import Combine



// MARK: - QuoteViewController
// Controller for displaying quotes. Connects the View and ViewModel.
class QuoteViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private let viewModel = QuoteViewModel() // ViewModel instance.
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init() // For publishing input events.
    private var cancellables =  Set<AnyCancellable>() // Stores subscriptions to avoid memory leaks.
    
    // MARK: - ViewController Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear) // Sends an event when the view appears.
    }
    
    // MARK: - Binding Method
    // Binds the ViewModel's outputs to update the View.
    private func bind () {
        let output =  viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchQuoteDidSucceed(let quote):
                    self?.quoteLabel.text = quote.content
                case .fetchQuoteDidFail(let error):
                    self?.quoteLabel.text = error.localizedDescription
                case .toggleButton(let isEnabled) :
                    self?.refreshButton.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        input.send(.refreshButtonDidTap) // Sends an event when the button is tapped.
    }
}
