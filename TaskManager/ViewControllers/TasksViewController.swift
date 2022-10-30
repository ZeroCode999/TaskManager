//
//  TasksViewController.swift
//  TaskManager
//
//  Created by a.sultanov on 24.09.22.
//

import UIKit

class TasksViewController: UITableViewController {
    
    private let cellID = "ToDoCell"
    var taskList: Task!
    
    var currentTask: [ToDo] = []
    var completedTask: [ToDo] = []
    
    private var dataManager: DataManagerProtocol!

    init(dataManager: DataManagerProtocol) {
      super.init(nibName: nil, bundle: nil)
      
      self.dataManager = dataManager
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        appendToDos()
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchDataToDo()
    }
    
    // MARK: Actions
    @objc private func addButtonPressed() {
        showAlert()
    }

}

// MARK: - TableView
extension TasksViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTask.count : completedTask.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Tasks" : "Completed Task"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = indexPath.section == 0 ? currentTask[indexPath.row] : completedTask[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteToDo(forRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toDo = indexPath.section == 0 ? currentTask[indexPath.row] : completedTask[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, _) in
            self.deleteToDo(forRowAt: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: toDo) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let title = indexPath.section == 0 ? "Done" : "Undone"
        let doneAction = UIContextualAction(style: .normal, title: title) { (_, _, isDone) in

            self.doneToDo(forRowAt: indexPath)
            
//            let indexPathForCurrentTask = IndexPath(row: self.currentTask.count - 1, section: 0)
//            let indexPathForComletedTask = IndexPath(row: self.completedTask.count - 1, section: 1)
//            
//            let destinationIndexRow = indexPath.section == 0 ? indexPathForComletedTask : indexPathForCurrentTask
//            
//            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            
            isDone(true)
            
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }

}

// MARK: - Alerts
extension TasksViewController {    
    private func showAlert(with toDo: ToDo? = nil, completion: (() -> Void)? = nil) {
        let title = toDo != nil ? "Edit ToDo" : "New ToDo"
        
        let alert = AlertController(title: title, message: "What do you want ToDo?", preferredStyle: .alert)
        
        alert.action(with: toDo) { newName, newNote in
            if let toDo = toDo, let completion = completion {
                self.editToDo(toDo: toDo, newName: newName, newNote: newNote)
                completion()
            } else {
                guard let toDo = alert.textFields?.first?.text, !toDo.isEmpty else { return }
                guard let note = alert.textFields?.last?.text, !note.isEmpty else { return }
                self.saveToDo(toDo, note)
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Manipulate with data
extension TasksViewController {
    private func appendToDos() {
        let todos = taskList.todos as! Set<ToDo>
        for item in todos where todos.contains(where: { ToDo in
            ToDo.isComplete == false
        }) {
            currentTask.append(item)
        }
        
        for item in todos where todos.contains(where: { ToDo in
            ToDo.isComplete == true
        }) {
            completedTask.append(item)
        }
    }
    
    private func fetchDataToDo() {
        currentTask = dataManager.fetchDataToDo()
        tableView.reloadData()
    }

    private func saveToDo(_ toDoName: String, _ toDoNote: String) {
        let toDo = dataManager.saveToDo(toDoName, toDoNote, in: taskList)
        currentTask.append(toDo)

        let cellIndex = IndexPath(row: currentTask.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func editToDo(toDo: ToDo, newName: String, newNote: String) {
        dataManager.editToDo(toDo: toDo, newName: newName, newNote: newNote)
    }
    
    private func doneToDo(forRowAt indexPath: IndexPath) {
        let indexPathForCurrentTask = IndexPath(row: currentTask.count - 1, section: 0)
        let indexPathForComletedTask = IndexPath(row: completedTask.count - 1, section: 1)
        
        let destinationIndexRow = indexPath.section == 0 ? indexPathForComletedTask : indexPathForCurrentTask
        if indexPath.section == 0 {
            currentTask.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let toDo = dataManager.doneToDo(indexPath: indexPath)
            completedTask.append(toDo)
            tableView.insertRows(at: [destinationIndexRow], with: .automatic)
        } else {
            completedTask.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let toDo = dataManager.doneToDo(indexPath: indexPath)
            currentTask.append(toDo)
            tableView.insertRows(at: [destinationIndexRow], with: .automatic)
        }
        
        //tableView.moveRow(at: indexPath, to: destinationIndexRow)
    }

    private func deleteToDo(forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            currentTask.remove(at: indexPath.row)
        } else {
            completedTask.remove(at: indexPath.row)
        }
        dataManager.deleteToDo(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
