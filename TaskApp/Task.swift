//
//  Task.swift
//  TaskApp
//
//  Created by Kosuke Miyazaki on 2024/04/29.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId

    // タイトル
    @Persisted var title = ""

    // 内容
    @Persisted var contents = ""

    // 日時
    @Persisted var date = Date()
    
    //カテゴリ
    @Persisted var category: String = ""

}
