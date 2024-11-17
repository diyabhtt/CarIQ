import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // UI Elements
    private let tableView = UITableView()
    private let inputContainerView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    // Data Source for Messages
    private var messages: [String] = []
    
    // Data from the file
    private var contextData: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the data file
        loadData()

        // Setup the Chat Interface
        setupTableView()
        setupInputContainer()
        setupConstraints()
    }

    // load
    private func loadData() {
        //let file2021Path = "/Users/diyabhattarai/Downloads/2021.txt"
        //let file2022Path = "/Users/diyabhattarai/Downloads/2022.txt"
        //let file2023Path = "/Users/diyabhattarai/Downloads/2023.txt"
        //let file2024Path = "/Users/diyabhattarai/Downloads/2024.txt"
        let file2025Path = "/Users/diyabhattarai/Downloads/2025.txt"
        
        var combinedData = ""
        
        
//        if let file2021Data = try? String(contentsOfFile: file2021Path) {
//            combinedData += file2021Data + "\n"
//        } else {
//            print("Error: Could not load data from \(file2021Path).")
//        }
        
        
//        if let file2022Data = try? String(contentsOfFile: file2022Path) {
//            combinedData += file2022Data + "\n"
//        } else {
//            print("Error: Could not load data from \(file2022Path).")
//        }
        
       
//        if let file2023Data = try? String(contentsOfFile: file2023Path) {
//            combinedData += file2023Data + "\n"
//        } else {
//            print("Error: Could not load data from \(file2023Path).")
//        }
        
        
//        if let file2024Data = try? String(contentsOfFile: file2024Path) {
//            combinedData += file2024Data + "\n"
//        } else {
//            print("Error: Could not load data from \(file2024Path).")
//        }
        
        
        if let file2025Data = try? String(contentsOfFile: file2025Path) {
            combinedData += file2025Data
        } else {
            print("Error: Could not load data from \(file2025Path).")
        }
        
        
        contextData = combinedData
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
        messages.append("You: \(text)")
        messageTextField.text = ""
        tableView.reloadData()
        scrollToBottom()

        // Fetch response from AI with context data
        fetchResponse(question: text)
    }

    // MARK: - Helper to Scroll to Bottom
    private func scrollToBottom() {
        let lastRowIndex = messages.count - 1
        if lastRowIndex >= 0 {
            let indexPath = IndexPath(row: lastRowIndex, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: - Fetch Response from AI
    private func fetchResponse(question: String) {
        let apiKey = "8976f8f7-39b8-44fa-bdb8-11d04138318c"  // Replace with your API key
        let url = URL(string: "https://api.sambanova.ai/v1/chat/completions")!
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        // Send context data with the question to the AI model
        let data: [String: Any] = [
            "model": "Meta-Llama-3.1-8B-Instruct",
            "messages": [
                ["role": "system", "content": "You are an AI that answers questions based on provided context data."],
                ["role": "system", "content": "Here is the context data: \(contextData)"],
                ["role": "user", "content": question]
            ],
            "temperature": 0.1,
            "top_p": 0.1
        ]

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: Request failed. \(error)")
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Error: Invalid response received.")
                return
            }

            guard let data = data,
                  let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = responseData["choices"] as? [[String: Any]],
                  let answer = choices.first?["message"] as? [String: Any],
                  let content = answer["content"] as? String else {
                print("Error: No valid answer received.")
                return
            }

            DispatchQueue.main.async {
                self.messages.append("AI: \(content)")
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }

        task.resume()
    }
}
