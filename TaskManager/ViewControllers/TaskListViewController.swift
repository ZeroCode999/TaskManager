//
//  ViewController.swift
//  TaskManager
//
//  Created by a.sultanov on 11.09.22.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var taskList: [Task] = []
    
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData()
    }

    // MARK: - Setup View
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 191/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: Actions
    @objc private func addNewTask() {
        showAlert()
    }
    
}

// MARK: - TableView
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delete(forRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = taskList[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, _) in
            self.delete(forRowAt: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(task: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
}

// MARK: - Alerts
extension TaskListViewController {
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit List" : "New List"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.action(with: task) { newValue in
            if let task = task, let completion = completion {
                self.edit(task: task, newName: newValue)
                completion()
            } else {
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Manipulate with data
extension TaskListViewController {
    private func fetchData() {
        taskList = dataManager.fetchData()
        tableView.reloadData()
    }

    private func save(_ taskName: String) {
        let task = dataManager.save(taskName)
        taskList.append(task)

        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func edit(task: Task, newName: String) {
        dataManager.edit(task: task, newName: newName)
    }

    private func delete(forRowAt indexPath: IndexPath) {
        taskList.remove(at: indexPath.row)
        dataManager.delete(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
