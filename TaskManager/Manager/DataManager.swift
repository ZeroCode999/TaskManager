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
    func saveToDo(_ toDoName: String, _ toDoNote: String, in taskList: Task) -> ToDo
    func editToDo(toDo: ToDo, newName: String, newNote: String)
    func fetchDataToDo() -> [ToDo]
    func deleteToDo(indexPath: IndexPath)
    func doneToDo(indexPath: IndexPath) -> ToDo
}

final class DataManager: DataManagerProtocol {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
    var datePredicate: NSPredicate?
      
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
    
    func fetchDataToDo() -> [ToDo] {
        var fetchingToDo = [ToDo]()
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
//        let curentDate = Date().timeIntervalSince1970
//        self.datePredicate = NSPredicate(format: "date >= %@", curentDate)
//
//        fetchRequest.predicate = datePredicate
        
        do {
            fetchingToDo = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        return fetchingToDo
    }
    
    func save(_ taskName: String) -> Task {
        let taskInstance = Task(context: context)
        taskInstance.name = taskName
        saveContext()
        return taskInstance
    }
    
    func saveToDo(_ toDoName: String, _ toDoNote: String, in taskList: Task) -> ToDo {
        let toDoInstance = ToDo(context: context)
        toDoInstance.name = toDoName
        toDoInstance.note = toDoNote
        toDoInstance.isComplete = false

        taskList.todos?.adding(toDoInstance)
        
        saveContext()
        return toDoInstance
    }
    
    func edit(task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func editToDo(toDo: ToDo, newName: String, newNote: String) {
        toDo.name = newName
        toDo.note = newNote
        saveContext()
    }
    
    func delete(indexPath: IndexPath) {
        let task = fetchData()
        context.delete(task[indexPath.row])
        saveContext()
    }
    
    func deleteToDo(indexPath: IndexPath) {
        let toDo = fetchDataToDo()
        context.delete(toDo[indexPath.row])
        saveContext()
    }
    
    func doneToDo(indexPath: IndexPath) -> ToDo {
        let toDo = fetchDataToDo()
        toDo[indexPath.row].isComplete.toggle()
        saveContext()
        return toDo[indexPath.row]
        
//        let toDo = fetchDataToDo()
//        context.delete(toDo[indexPath.row])
//        context.add(toDo[indexPath.row])
//        context.inde
//        toDo[indexPath.row].isComplete.toggle()
//        saveContext()
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
