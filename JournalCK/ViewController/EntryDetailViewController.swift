//
//  EntryDetailViewController.swift
//  JournalCK
//
//  Created by Brady Bentley on 12/31/18.
//  Copyright © 2018 Brady. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    
    // MARK: - Properties
    var entry: Entry?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - IBActions
    @IBAction func clearTextButtonTapped(_ sender: Any) {
        titleTextField.text = ""
        bodyTextView.text = ""
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard titleTextField.text != "", bodyTextView.text != "", let title = titleTextField.text, let body = bodyTextView.text else { return }
        
        if let entry = entry {
           // modify entry
            EntryController.shared.updateEntry(entry: entry, title: title, body: body) { (success) in
                if success {
                   print("Success updating an entry")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Failure to update entry")
                }
            }
        } else {
            //create entry
            EntryController.shared.addEntryWith(title: title, body: body) { (success) in
                if success {
                    print("Success adding an entry")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Failure to create entry")
                }
            }
        }
    }
    
    func updateViews() {
        guard let entry = entry else { return }
        titleTextField.text = entry.title
        bodyTextView.text = entry.body
    }
}

// MARK: - UITextFieldDelegate
extension EntryDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
