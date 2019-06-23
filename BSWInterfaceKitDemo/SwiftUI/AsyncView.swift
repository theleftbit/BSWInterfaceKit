//
//  Created by Pierluigi Cifani on 23/06/2019.
//

import BSWInterfaceKit
import BSWFoundation
import SwiftUI

struct ToDoList: View, ViewModelInitiable {
    let todos: [ToDo]
    
    init(vm: [ToDo]) {
        self.todos = vm
    }
    
    var body: some View {
        List(todos.identified(by: \.id)) { todo in
            ToDoRow(toDo: todo)
        }
    }
    
    enum Factory {
        static func todoList() -> some View {
            NavigationView(root: {
                AsyncView<ToDoList>(dataFetcher: apiClient.fetchTodos().future)
                .navigationBarTitle(Text("ToDos"))
            })
        }

        static func todoListAsUIKit() -> UIViewController {
            let view =
                AsyncView<ToDoList>(dataFetcher: apiClient.fetchTodos().future)
                .navigationBarTitle(Text("ToDos"))
            return UIHostingController(rootView: view)
        }
    }
}

struct ToDoRow: View {
    let toDo: ToDo
    var body: some View {
        HStack {
            Text(toDo.title)
            Spacer()
            toDo.completed ? Image(systemName: "checkmark") : Image(systemName: "xmark.octagon")
            }.padding()
    }
}

struct ToDo: Codable, Hashable {
    let id: Int
    let title: String
    let completed: Bool
}

// Crap to make the above compile

import Task

private let apiClient = TodoAPIClient()

private class TodoAPIClient: APIClient {
    
    init() {
        super.init(environment: Environment.production)
    }
    
    func fetchTodos() -> Task<[ToDo]> {
        return self.perform(Request(endpoint: Endpoints.todos))
    }
    
    enum Environment: BSWFoundation.Environment {
        case production
        var baseURL: URL {
            return URL(string: "https://jsonplaceholder.typicode.com")!
        }
    }
    
    enum Endpoints: BSWFoundation.Endpoint {
        case todos
        
        var path: String {
            return "/todos"
        }
    }
}

