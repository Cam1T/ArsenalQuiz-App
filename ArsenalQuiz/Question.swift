//
//  Question.swift
//  ArsenalQuiz
//
//  Created by USER on 31/08/2020.
//  Copyright © 2020 CJAPPS. All rights reserved.
//

import Foundation

struct Question:Codable {
    
    var question:String?
    var answers:[String]?
    var correctAnswerIndex:Int?
    var feedback:String?
}
