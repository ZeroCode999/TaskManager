//
//  DataManager.swift
//  TaskManager
//
//  Created by a.sultanov on 18.09.22.
//

import UIKit
import CoreData

protocol DataManagerProtocol {
    func save(_ taskName: String) -> Task
    func edit(task: Task, newName: String)
    func fetchData() -> [Task]
    func delete(indexPath: IndexPath)
}

final class DataManager: DataManagerProtocol {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      
    func fetchData() -> [Task] {
        var fetchingTasks = [Task]()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            fetchingTasks = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        return fetchingTasks
    }
    
    func save(_ taskName: String) -> Task {
        let taskInstance = Task(context: context)
        taskInstance.name = taskName
        saveContext()
        return taskInstance
    }
    
    func edit(task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func delete(indexPath: IndexPath) {
        let task = fetchData()
        context.delete(task[indexPath.row])
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    private func saveContext() {
      do {
        try context.save()
      } catch {
        print(error.localizedDescription)
      }
    }
}
