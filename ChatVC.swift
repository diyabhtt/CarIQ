import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // UI Elements
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    // Data Source for Messages
    private var messages: [String] = []
    private var aiResponses: [String] = []

    private let apiKey = "555f69be-20cc-428f-bdd6-2ef72033279c"
    private let apiUrl = "https://api.sambanova.ai/v1/chat/completions"

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
        messageTextField.returnKeyType = .send // Set Return key to "Send"
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
        return messages.count + aiResponses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        // Alternate between user and AI messages
        if indexPath.row % 2 == 0 {
            cell.textLabel?.text = messages[indexPath.row / 2]  // User message
            cell.textLabel?.textColor = .blue
        } else {
            cell.textLabel?.text = aiResponses[(indexPath.row - 1) / 2]  // AI message
            cell.textLabel?.textColor = .gray
        }
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - Send Button Action
    @objc private func sendButtonTapped() {
        sendMessage()
    }

    // MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }

    // MARK: - Send Message Logic
    private func sendMessage() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        messages.append(text) // Add user's message
        messageTextField.text = ""
        tableView.reloadData()
        scrollToBottom()

        // Send the question to AI after user input
        fetchAIResponse(userMessage: text)
    }

    // MARK: - AI Chat API Call
    private func fetchAIResponse(userMessage: String) {
        // Prepare the data for the API request
        let data: [String: Any] = [
            "model": "Meta-Llama-3.2-3B-Instruct",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant"],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.1,
            "top_p": 0.1
        ]
        
        // Set up the URLRequest
        guard let url = URL(string: apiUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the data to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Failed to serialize data: \(error)")
            return
        }
        
        // Send the request using URLSession
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let aiResponse = choices.first?["message"] as? [String: Any],
                   let content = aiResponse["content"] as? String {
                    DispatchQueue.main.async {
                        self?.aiResponses.append(content)
                        self?.tableView.reloadData()
                        self?.scrollToBottom()
                    }
                }
            } catch {
                print("Error parsing AI response: \(error)")
            }
        }
        
        task.resume()
    }

    // MARK: - Helper to Scroll to Bottom
    private func scrollToBottom() {
        let lastRowIndex = messages.count + aiResponses.count - 1
        if lastRowIndex >= 0 {
            let indexPath = IndexPath(row: lastRowIndex, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

