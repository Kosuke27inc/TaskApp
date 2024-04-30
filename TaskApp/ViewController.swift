//
//  ViewController.swift
//  TaskApp
//
//  Created by Kosuke Miyazaki on 2024/04/21.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    // DB内のタスクが格納されるリスト
    var taskArray: Results<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0 // 推定の行の高さ
        tableView.delegate = self
        tableView.dataSource = self
        
        // Realmインスタンスを取得し、TaskItemオブジェクトのリストを取得する
        let realm = try! Realm()
        taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        
        // SearchBarのデリゲートを設定
        if let searchBar = self.navigationItem.titleView as? UISearchBar {
            searchBar.delegate = self
        }
        
        //キーボードを隠すやつ
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let inputViewController = segue.destination as? InputViewController {
            if segue.identifier == "cellSegue", let indexPath = tableView.indexPathForSelectedRow {
                // ここでTaskItemオブジェクトを渡す
                inputViewController.task = taskArray?[indexPath.row]
            } else {
                // 新しいTaskを作成し、InputViewControllerで処理する
                let newTask = Task()
                let realm = try! Realm()
                try! realm.write {
                    realm.add(newTask)
                }
                inputViewController.task = newTask
            }
        }
    }
    
    // 入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // テーブルビューのデータソースメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let task = taskArray?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = task.title
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: task.date)
            content.secondaryText = dateString
            cell.contentConfiguration = content
        }
        
        return cell
    }
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // セルが削除可能かを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let taskToDelete = taskArray?[indexPath.row] {
                // ローカル通知をキャンセルする
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: [taskToDelete.id.stringValue])
                
                // データベースから削除する
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.delete(taskToDelete)
                    }
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    print("Error deleting task: \(error)")
                }
            }
        }
    }
    // UISearchBarDelegate メソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 検索バーが空の場合は全てのタスクを表示
            let realm = try! Realm()
            taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        } else {
            // 検索テキストに基づいてタスクを絞り込む
            let realm = try! Realm()
            taskArray = realm.objects(Task.self).filter("category CONTAINS[c] %@", searchText).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()
    }
    
    // UISearchBarのキャンセルボタンが押された時の処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        // 検索バーが空になった時点で全てのタスクを表示
        let realm = try! Realm()
        taskArray = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
}
