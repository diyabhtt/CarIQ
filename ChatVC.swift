//
//  ChatVC.swift
//  CARIQ
//
//  Created by Diya Bhattarai on 11/17/24.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // UI Elements
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    // Data Source for Messages
    private var messages: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Chat Interface
        setupTableView()
        setupInputContainer()
        setupConstraints()
    }

    // MARK: - TableView Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }

    // MARK: - Input Container Setup
    private func setupInputContainer() {
        inputContainerView.backgroundColor = .lightGray
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainerView)

        // Message Text Field
        messageTextField.placeholder = "Type a message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(messageTextField)

        // Send Button
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(sendButton)
    }

    // MARK: - Constraints Setup
    private func setupConstraints() {
        // TableView Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])

        // Input Container Constraints
        NSLayoutConstraint.activate([
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Message TextField Constraints
        NSLayoutConstraint.activate([
            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 10),
            messageTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 35)
        ])

        // Send Button Constraints
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 10),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10)
        ])
    }

    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - Send Button Action
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        messages.append(text)
        messageTextField.text = ""
        tableView.reloadData()
        scrollToBottom()
    }

    // MARK: - Helper to Scroll to Bottom
    private func scrollToBottom() {
        let lastRowIndex = messages.count - 1
        if lastRowIndex >= 0 {
            let indexPath = IndexPath(row: lastRowIndex, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

