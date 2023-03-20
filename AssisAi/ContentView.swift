import SwiftUI
import Combine
struct ContentView: View {
    @State var messageText: [MessageText] = []
    @State private var messageToSend = ""
    @State var cancellabels = Set<AnyCancellable>()
    let openAiService = OpenAiService()
    let openAIKey = ""
    let apiURL = URL(string: "https://api.openai.com/v1/engines/davinci-codex/completions")!
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(messageText, id: \.id) { message in
                        messageView(message: message)
                            .padding(.bottom)
                    }
                   
                }
                
                
            }
            HStack {
                TextField("Message", text: $messageToSend) {
                    
                }
                    .padding()
                    .foregroundColor(.primary)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(16)
                    //.textFieldStyle(RoundedBorderTextFieldStyle())
                    
                Button {
                    sendMessage()
                } label: {
                    Text("Send")
                        .foregroundColor(.primary)
                        .padding()
                        .background(.primary)
                        .cornerRadius(16)
                        
                }

            }
            .padding()
            
            
        }
        
        
    }
    func messageView(message: MessageText) -> some View {
        HStack {
            if message.sender == .me {Spacer()
                Text(message.content)
                    .foregroundColor(message.sender == .me ? .white : .primary)
                    .padding()
                    .background(message.sender == .me ? .blue : .secondary.opacity(0.4))
                    .cornerRadius(16)
                Image("avatar" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .cornerRadius(22.5)
            }
            if message.sender == .chatGpt {
                Image("GPTLogo" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
                    .cornerRadius(22.5)
                Text(message.content)
                    .foregroundColor(message.sender == .me ? .white : .primary)
                    .padding()
                    .background(message.sender == .me ? .blue : .secondary.opacity(0.4))
                    .cornerRadius(16)
                Spacer()
            }
            
            
        }
    }
    
    func sendMessage() {
        let myMessage = MessageText(id: UUID().uuidString, content: messageToSend, dateCreated: Date(), sender: .me)
        messageText.append(myMessage)
        openAiService.sendMessage(message: messageToSend).sink { completion in
            // Handle Errors
        } receiveValue: { response in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else {return}
            let gptMessage = MessageText(id: response.id, content: textResponse, dateCreated: Date(), sender: .chatGpt)
            messageText.append(gptMessage)
        }
        .store(in: &cancellabels)

        messageToSend = ""
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MessageText {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}


enum MessageSender {
    case me, chatGpt
}

extension MessageText {
    static let sampleMessages = [
        MessageText(id: UUID().uuidString, content: "Sample Message From Me", dateCreated: Date(), sender: .me),
        MessageText(id: UUID().uuidString, content: "Sample Message From ChatGpt", dateCreated: Date(), sender: .chatGpt),
        MessageText(id: UUID().uuidString, content: "Sample Message From Me", dateCreated: Date(), sender: .me),
        MessageText(id: UUID().uuidString, content: "Sample Message From ChatGpt", dateCreated: Date(), sender: .chatGpt)
    ]
}

