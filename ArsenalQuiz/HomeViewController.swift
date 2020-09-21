//
//  HomeViewController.swift
//  ArsenalQuiz
//
//  Created by USER on 08/09/2020.
//  Copyright © 2020 CJAPPS. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


    @IBAction func playTapped(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "goToQuiz", sender: self)
    }
}
