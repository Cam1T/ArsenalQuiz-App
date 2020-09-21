//
//  ResultViewController.swift
//  ArsenalQuiz
//
//  Created by USER on 01/09/2020.
//  Copyright © 2020 CJAPPS. All rights reserved.
//

import UIKit

protocol ResultViewControllerProtocol {
    func dialogDismissed()
}

class ResultViewController: UIViewController {
    
    
    @IBOutlet var dimView: UIView!
    
    @IBOutlet var dialogueView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var feedbackLabel: UILabel!
    
    @IBOutlet var dismissButton: UIButton!
    
    var titleText      = ""
    var feedbackText   = ""
    var buttonText     = ""
    
    var delegate:ResultViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the dialog box corners
        dialogueView.layer.cornerRadius = 10
        
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Now that the elements are loading set the text.
        titleLabel.text = titleText
        feedbackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        // Hide the UI Elements
        dimView.alpha = 0
        titleLabel.alpha = 0
        feedbackLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Fade in the elements
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 1
            self.titleLabel.alpha = 1
            self.feedbackLabel.alpha = 1
        }, completion: nil)
    }
    

    @IBAction func dismissTapped(_ sender: Any) {
        
        // Fade out the dim view and then dismiss the popup
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.dimView.alpha = 0
        
        }) { (completed) in
            
            //  Dismiss the popup
            self.dismiss(animated: true, completion: nil)
            
            // Notify delegate that the popup was dismissed
            self.delegate?.dialogDismissed()
            
        }

    }
    
}
