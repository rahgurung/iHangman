//
//  ViewController.swift
//  iHangman
//
//  Created by Rahul Gurung on 02/09/24.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Private properties
    private var wordToGuess: String = ""
    private var wordLabel: UILabel!
    private var mainStackView: UIStackView!
    private let textField = UITextField()
    private var livesLabel: UILabel!
    private var lives = 7 {
        didSet {
            livesLabel.text = String("Lives left: \(lives)")
        }
    }

    // MARK: - View lifecycle overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadWord), with: nil)
    }
    
    override func loadView() {
        view = UIView()
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        livesLabel = UILabel()
        livesLabel.translatesAutoresizingMaskIntoConstraints = false
        livesLabel.textAlignment = .right
        lives = 7

        view.backgroundColor = .white
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(livesLabel)

        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.textAlignment = .right
        wordLabel.text = ""
        mainStackView.addArrangedSubview(wordLabel)
        
        // Add textfield
        textField.placeholder = "Enter character here"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = UIColor(white: 0.9, alpha: 1)
        mainStackView.addArrangedSubview(textField)

        // Add submit button
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    
        mainStackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func loadWord() {
        // Load clue from file
        if let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let wordsContents = try? String(contentsOf: wordsFileURL) {
                let lines = wordsContents.components(separatedBy: "\n")
                if let randomWord = lines.randomElement() {
                    wordToGuess = randomWord
                    startGame()
                }
            }
        }
    }
    
    // Action handler for the button
    @objc func buttonTapped() {
        guard let inputText = textField.text, !inputText.isEmpty else {
            print("Text field is empty")
            return
        }

        // Clear the text
        textField.text = ""

        if (inputText.count > 1) {
            showErrorMessage(title: "Please enter only 1 character", message: "")
        }

        // Edit the text reveal the given character if matching
        if(wordToGuess.contains(inputText.lowercased())) {
            // Get indexs of character from wordToGuess
            var matchingIndexes: [Int] = []

            for (index, letter) in wordToGuess.enumerated() {
                if String(letter.lowercased()) == inputText.lowercased() {
                    matchingIndexes.append(index)
                }
            }

            // replace given indexes with that index
            var oldWordArray = Array(self.wordLabel.text!)
            for index in matchingIndexes {
                oldWordArray[index] = Character(inputText)
            }

            wordLabel.text = String(oldWordArray)

            // Check if all letter are guessed, show congrats message
            var didUserWin = true
            for char in oldWordArray {
                if char == "?" {
                    didUserWin = false
                }
            }
            if didUserWin {
                showErrorMessage(title: "You won", message: "")
                performSelector(inBackground: #selector(loadWord), with: nil)
            }
        } else {
            lives -= 1
            if(lives == 0) {
                performSelector(inBackground: #selector(loadWord), with: nil)
                showErrorMessage(title: "You lost", message: "")
            } else {
                showErrorMessage(title: "Sorry! This letter is not part of word", message: "")
            }
        }
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: - Private methods
    private func startGame() {
        DispatchQueue.main.async { [weak self] in
            if let wordToGuess = self?.wordToGuess {
                self?.wordLabel.text = String(wordToGuess.map { _ in "?" })
                self?.lives = 7
            }
        }
    }
}

