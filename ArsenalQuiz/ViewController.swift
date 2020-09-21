//
//  ViewController.swift
//  ArsenalQuiz
//
//  Created by USER on 31/08/2020.
//  Copyright © 2020 CJAPPS. All rights reserved.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    
    
    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var stackViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var rootStackView: UIStackView!
    
    @IBOutlet var questionLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var model = QuizModel()
    var questions = [Question]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    
    var resultDialog:ResultViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Initialise the result dialog
        resultDialog = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // Set self as the delegate and datasource for the tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        // Dynamic Row Heights
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        // Set up the model
        model.delegate = self
        model.getQuestions()
        
    }
    func slideInQuestion() {
        
        // Set the initial state
        stackViewTrailingConstraint.constant = -1000
        stackViewLeadingConstraint.constant = 1000
        rootStackView.alpha = 0
        view.layoutIfNeeded()
        
        // Animate it to the end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.stackViewLeadingConstraint.constant = 0
            self.stackViewTrailingConstraint.constant = 0
            self.rootStackView.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        
    }
    
    func slideOutQuestion() {
        
        // Set the initial state
        stackViewTrailingConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        rootStackView.alpha = 1
        view.layoutIfNeeded()
        
        // Animate it to the end state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.stackViewLeadingConstraint.constant = -1000
            self.stackViewTrailingConstraint.constant = 1000
            self.rootStackView.alpha = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    func displayQuestion() {
        
        // Check if there are questions and check that the currentquestionindex is not out of bounds
        
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // Display the question text
        questionLabel.text = questions[currentQuestionIndex].question
        
        // Reload the answers table
        tableView.reloadData()
        
        // Animate the question in
        slideInQuestion()
    }
    
    
    // MARK: - Quiz Protocol Methods
    
    func questionsRetrieved(_ questions: [Question]) {
        
        // Get a reference to the questions
        self.questions = questions
        
        // Check if we should restore the state before showing question  #1
        let savedIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        if savedIndex != nil && savedIndex! < self.questions.count {
            // Set the current question to the saved index
            currentQuestionIndex = savedIndex!
            
            // Retrieve the number correct from Storage
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                numCorrect = savedNumCorrect!
            }
            
            
        }
        
        
        // Display the first question
        displayQuestion()
        
        
    }
    
    
    // MARK: - UITableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure the questions array contains a question
        guard questions.count > 0 else {
            return 0
        }
        // Return the number of answers for this question
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get  cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // Customize it
        let label = cell.viewWithTag(1) as? UILabel
        
        if label != nil {
            let question = questions[currentQuestionIndex]
            
            if question.answers != nil && indexPath.row < question.answers!.count {
                
                // Set the answer text for the label
                label!.text = question.answers![indexPath.row]
            }
            
        }
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleText = ""
        
        // User has tapped on a row, check if it's the right answer
        let question = questions[currentQuestionIndex]
        
        if question.correctAnswerIndex! == indexPath.row {
            // User has got it right
            titleText = "Correct!"
            numCorrect += 1
        }
        else {
            // User got it wrong
            titleText = "Wrong!"
        }
        
        DispatchQueue.main.async {
            self.slideOutQuestion()
        }
        
        // Show the popup
        if resultDialog != nil {
            
            // Customize the dialog text
            resultDialog!.titleText = titleText
            resultDialog!.feedbackText = question.feedback!
            resultDialog!.buttonText = "Next"
            
            DispatchQueue.main.async {
                self.present(self.resultDialog!, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - ResultViewControllerProtocol Methods
    
    func dialogDismissed() {
        
        // Increment the currentQuestionindex
        currentQuestionIndex += 1
        
        if currentQuestionIndex == questions.count {
            
            // The user has just answered the last question
            // Show a summary Dialog
            if resultDialog != nil {
                
                // Customize the dialog text
                resultDialog!.titleText = "Summary"
                resultDialog!.feedbackText = "You got \(numCorrect) correct out of \(questions.count) questions"
                resultDialog!.buttonText = "Restart"
                present(resultDialog!, animated: true, completion: nil)
                
                // Clear State
                StateManager.clearState()
            }
        }
        else if currentQuestionIndex > questions.count {
            
            // Restart
            numCorrect = 0
            currentQuestionIndex = 0
            
            // Display and animate in the question
            displayQuestion()
        }
        else if currentQuestionIndex < questions.count {
            // We have more questions to show
            
            // Display the next question
            displayQuestion()
            
            
            // Save State
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)
            
            
        }
        
    }
    
    
}
