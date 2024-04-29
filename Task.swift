//
//  Task.swift
//  
//
//  Created by Kosuke Miyazaki on 2024/04/26.
//

import RealmSwift


import RealmSwift

class Task: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var contents: String = ""
    @Persisted var date: Date = Date()
}
