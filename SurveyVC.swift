//
//  SurveyVC.swift
//  CARIQ
//
//  Created by Diya Bhattarai on 11/17/24.
//

import UIKit

class SurveyVC: UIViewController {
    @IBOutlet var questionLabel: UILabel!
    
    @IBOutlet var choicesButton: [UIButton]!
    // Data for questions and answers
        private let questions = [
            "What year do you prefer?",
            "What type of transmission do you want?",
            "Do you prefer an electric or gas vehicle?",
            "Do you drive on highways a lot?"
        ]

        private let answers: [[String]] = [
            ["2020", "2021", "2022", "2023", "2024"], // Year options
            ["Manual", "Automatic", "Semi-Automatic"], // Transmission options
            ["Electric", "Gas"], // Fuel options
            ["Yes", "No"] // Highway driving
        ]

        // Example Toyota cars data
        private let toyotaCars = [
            ["Toyota Prius", "2024", "Electric", "Automatic"],
            ["Toyota Camry", "2023", "Gas", "Automatic"],
            ["Toyota Corolla", "2022", "Gas", "Manual"],
            ["Toyota RAV4", "2024", "Gas", "Automatic"],
            ["Toyota bZ4X", "2023", "Electric", "Automatic"]
        ]

        // User selections
        private var userSelections: [String] = []

        // Current question index
        private var currentQuestionIndex = 0

        override func viewDidLoad() {
            super.viewDidLoad()
            loadQuestion()
        }

        // Load the current question and answer choices
        private func loadQuestion() {
            questionLabel.text = questions[currentQuestionIndex]
            let currentAnswers = answers[currentQuestionIndex]

            // Configure buttons based on the number of answer choices
            for (index, button) in choicesButton.enumerated() {
                if index < currentAnswers.count {
                    button.setTitle(currentAnswers[index], for: .normal)
                    button.isHidden = false
                } else {
                    button.isHidden = true
                }
            }
        }

        // Handle button tap to record the answer
        @IBAction func choiceButtonTapped(_ sender: UIButton) {
            guard let answer = sender.title(for: .normal) else { return }

            // Save user selection
            userSelections.append(answer)

            // Load the next question or finish the survey
            currentQuestionIndex += 1
            if currentQuestionIndex < questions.count {
                loadQuestion()
            } else {
                finishSurvey()
            }
        }

        // Finish survey and handle the collected data
        private func finishSurvey() {
            // Find the best matching Toyota car
            let recommendedCar = findBestMatchingCar()

            // Display the result in a pop-up
            showRecommendationPopup(car: recommendedCar)
        }

        // Match user selections to the best Toyota car
        private func findBestMatchingCar() -> String {
            var bestMatch: String = "No match found"
            var bestScore = 0

            for car in toyotaCars {
                var score = 0

                // Compare year, fuel type, transmission, and highway driving
                if userSelections[0] == car[1] { score += 1 } // Year
                if userSelections[1] == car[3] { score += 1 } // Transmission
                if userSelections[2] == car[2] { score += 1 } // Fuel type
                if userSelections[3] == "Yes" { score += 1 } // Highway driving preference

                if score > bestScore {
                    bestScore = score
                    bestMatch = car[0]
                }
            }

            return bestMatch
        }

        // Show recommendation pop-up
        private func showRecommendationPopup(car: String) {
            let alert = UIAlertController(
                title: "Recommended Car",
                message: "We recommend the \(car) based on your preferences!",
                preferredStyle: .alert
            )

            let homeAction = UIAlertAction(title: "Home", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }

            alert.addAction(homeAction)
            present(alert, animated: true, completion: nil)
        }
    }
