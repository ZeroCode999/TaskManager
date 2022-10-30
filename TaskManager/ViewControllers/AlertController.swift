//
//  AlertController.swift
//  TaskManager
//
//  Created by a.sultanov on 18.09.22.
//

import UIKit

final class AlertController: UIAlertController {
    var doneButton = "Save"
        
    func action(with taskList: Task?, completion: @escaping (String) -> Void) {
        
        if taskList != nil {
            doneButton = "Update"
        }
                
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(with toDo: ToDo?, completion: @escaping (String, String) -> Void) {
                        
        if toDo != nil {
            doneButton = "Update"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newToDo = self.textFields?.first?.text else { return }
            guard !newToDo.isEmpty else { return }
            
            if let newNote = self.textFields?.last?.text, !newNote.isEmpty {
                completion(newToDo, newNote)
            } else {
                completion(newToDo, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "Name ToDo"
            textField.text = toDo?.name
        }
        
        addTextField { textField in
            textField.placeholder = "Note"
            textField.text = toDo?.note
        }
    }
}
