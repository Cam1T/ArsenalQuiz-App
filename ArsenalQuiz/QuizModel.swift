//
//  QuizModel.swift
//  ArsenalQuiz
//
//  Created by USER on 31/08/2020.
//  Copyright © 2020 CJAPPS. All rights reserved.
//

import Foundation

protocol QuizProtocol {
    
    func questionsRetrieved(_ questions:[Question])
}

class QuizModel {
    
    var delegate: QuizProtocol?
    
    func getQuestions() {
        
        // Fetch the questions
        getLocalJsonFile()
        
    }
    
    func getLocalJsonFile() {
        
        // Get a bundle path to the Json File
        let path = Bundle.main.path(forResource: "QuestionData", ofType: "json")
        
        // Double check that the path isn't nil
        guard path != nil else {
            print( "couldn't find the json data file")
            return
        }
        
        // Create a url object from the path
        let url = URL(fileURLWithPath: path!)
        
        do {
            
            // Get the data from the URL
            let data = try Data(contentsOf: url)
            
            // Try to decode the data into objects
            let decoder = JSONDecoder()
            let array = try decoder.decode([Question].self, from: data)
            
            // Notify the delegate of the parsed objects
            delegate?.questionsRetrieved(array)
            
        }
        catch {
            // Error: Couldn't download the data at that URL
        }
    }
    
    func getRemoteJsonFile() {
        
        // Get a URL Object
        let urlString = "https://raw.githubusercontent.com/CJTAWIAH/ArsenalJson/master/QuestionData.json"
        
        let url = URL(string: urlString)
        
        guard url != nil else {
            print("Couldn't create the URL Object")
            return
        }
        
        // Get a URL Session Object
        let session = URLSession.shared
        
        // Get a data Task object
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            
            // Check that there wasn't an error
            if error == nil && data != nil {
                
                
                do {
                    // Create a Json Decoder object
                    let decoder = JSONDecoder()
                    
                    // Parse the JSON
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // Use the main thread to notify the view controller for UI Work
                    DispatchQueue.main.async {
                        
            
                        // Notify the view controller
                        self.delegate?.questionsRetrieved(array)
                    }
                }
                catch {
                    print("Couldn't parse JSON")
                }
                
            }
        }
        
        // Call resume on the data task
        dataTask.resume()
    }
    
}
