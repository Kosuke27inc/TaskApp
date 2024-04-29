//
//  ViewController.swift
//  TaskApp
//
//  Created by Kosuke Miyazaki on 2024/04/21.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    // 15行目のエラー修正: taskArrayの宣言をクラスのプロパティに移動
    var taskArray: Results<Task>? // DB内のタスクが格納されるリスト

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0 // 推定の行の高さ
        tableView.delegate = self
        tableView.dataSource = self

        // 26行目のエラー修正: RealmのクエリをviewDidLoad内で実行
        let realm = try! Realm()
        taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    }

    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 35行目のエラー修正: as! から安全なキャストに変更し、存在を確認
        if let inputViewController = segue.destination as? InputViewController {
            if segue.identifier == "cellSegue" {
                if let indexPath = tableView.indexPathForSelectedRow {
                    // ここでTaskオブジェクトを渡す
                    inputViewController.task = taskArray?[indexPath.row]
                }
            } else {
                // 38行目のエラー修正: 新しいTaskをInputViewControllerで処理するよう変更
                inputViewController.task = Task()
            }
        }
    }

    // 入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // 以下、テーブルビューのデリゲートとデータソースメソッド
    // ...

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // ...
    }
}
