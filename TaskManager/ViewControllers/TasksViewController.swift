//
//  TasksViewController.swift
//  TaskManager
//
//  Created by a.sultanov on 24.09.22.
//

import UIKit

class TasksViewController: UITableViewController {
    
    private let cellID = "cell"
    var taskList: Task!
    
    var currentTask: [ToDo] = []
    var completedTask: [ToDo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
//        currentTask = taskList.tasks.filter("isComplete = false")
//        completedTask = taskList.tasks.filter("isComplete = true")
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.perform(#selector(goBack), with: self, afterDelay: 1.0)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTask.count : completedTask.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Tasks" : "Completed Task"
    }

    @objc private func addButtonPressed() {
        //showAlert()
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

}
