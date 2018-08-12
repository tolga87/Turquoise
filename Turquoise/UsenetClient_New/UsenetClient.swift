//
//  UsenetClient.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

private struct RequestResponseCallbackPair {
    let request: NNTPRequest
    let responseCallback: NNTPRequestCompletion?

    init(request: NNTPRequest, responseCallback: NNTPRequestCompletion?) {
        self.request = request
        self.responseCallback = responseCallback
    }
}

typealias UsenetClientRequestCallback = (String?) -> Void

class UsenetClient : UsenetClientInterface {
    static let sharedInstance = UsenetClient()

    static let newsServerHostName = "news.ceng.metu.edu.tr"
    static let newsServerPort = 563
    static let timeout: TimeInterval = 10

    fileprivate var streamTask: URLSessionStreamTask!
    fileprivate var dataBuffer: Data?
    private var queue: [RequestResponseCallbackPair] = []
    private var isInitialized = false

    private func enqueue(request: NNTPRequest, completion: NNTPRequestCompletion?) {
        let pair = RequestResponseCallbackPair(request: request, responseCallback: completion)
        self.queue.append(pair)
    }

    private func dequeue() {
        guard !self.queue.isEmpty else {
            return
        }
        self.queue.removeFirst()
    }

    public func connect() {
        self.setupStream()
    }

    private func setupStream() {
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        self.streamTask = session.streamTask(withHostName: UsenetClient.newsServerHostName,
                                             port: UsenetClient.newsServerPort)
        self.streamTask.startSecureConnection()

        self.makeRequest(NNTPRequest(string: "")) { (response) in
            guard let response = response else {
                return
            }
        }
    }

    private func processQueueIfNecessary() {
        guard let firstPair = self.queue.first else {
            return
        }

        self.sendRequest(firstPair.request.string) { (responseString) in
            self.dequeue()

            guard let responseCallback = firstPair.responseCallback else {
                self.processQueueIfNecessary()
                return
            }

            guard let responseString = responseString else {
                responseCallback(nil)
                self.processQueueIfNecessary()
                return
            }

            let response = NNTPResponseFactory.responseFrom(string: responseString)
            self.processQueueIfNecessary()
            responseCallback(response)
        }
    }

    // MARK: - UsenetClientInterface

    func makeRequest(_ request: NNTPRequest, completion: NNTPRequestCompletion?) {
        if !self.isInitialized {
            self.isInitialized = true
            self.setupStream()
        }

        self.enqueue(request: request, completion: completion)

        if self.queue.count == 1 {
            self.processQueueIfNecessary()
        }
    }

}

// MARK: - Network Code

extension UsenetClient {
    func sendRequest(_ requestString: String, completion: @escaping UsenetClientRequestCallback) {
        guard let streamTask = self.streamTask else {
            completion(nil)
            return
        }

        func receiveData() {
            self.bufferData(partNo: 0, completion: { (data: Data?) in
                guard let data = data else {
                    completion(nil)  // TODO: error.
                    return
                }

                let responseString = String(data: data, encoding: .utf8)
                //                                let response = TQNNTPResponse(string: responseString)

                let shouldTruncate = false
                let maxLengthToDisplay = shouldTruncate ? 150 : Int.max
                let responseLength = Int(responseString?.count ?? 0)

                if let responseString = responseString {
                    if responseLength > maxLengthToDisplay {
                        let truncatedResponseStringEndIndex = responseString.index(responseString.startIndex,
                                                                                   offsetBy: maxLengthToDisplay)
                        let truncatedResponseString = responseString.substring(to: truncatedResponseStringEndIndex)
                        printDebug("📡 \(truncatedResponseString) <TRUNCATED (\(responseLength))>")
                    } else {
                        printDebug("📡 \(responseString)")
                    }
                }

                completion(responseString)
            })
        }

        if requestString.isEmpty {
            // When the connection is first established, server immediately sends some data.
            receiveData()
            self.streamTask.resume()
        } else {
            printDebug("📱 \(requestString)")

            let requestData = requestString.data(using: .utf8)!
            streamTask.write(requestData, timeout: UsenetClient.timeout) { (error) in
                guard error == nil else {
                    completion(nil)
                    return
                }
                receiveData()
            }
        }
    }

    func bufferData(partNo: Int, completion: @escaping (_ data: Data?) -> Void) {
        guard let streamTask = self.streamTask else {
            return
        }

        streamTask.readData(ofMinLength: 0,
                            maxLength: 10000,
                            timeout: UsenetClient.timeout) { (data, atEOF, error) in
                                guard let data = data else {
                                    completion(nil)
                                    return
                                }

                                var isMultiLine: Bool = true

                                if partNo == 0 {
                                    self.dataBuffer = Data()
                                    var statusCode = 0

                                    if data.count >= 3 {
                                        // first 3 bytes must contain the status code.
                                        let responseCodeData = data.subdata(in: 0..<3)
                                        let responseCodeString = String(data: responseCodeData, encoding: .utf8) ?? ""
                                        statusCode = Int(responseCodeString) ?? 0
                                        isMultiLine = NNTPResponse.isMultiLine(statusCode)
                                    } else {
                                        // TODO: we shouldn't receive fewer than 3 bytes in the first part.
                                        //       if this happens, something's wrong. look into this.
                                    }
                                } else {
                                    printDebug("\t\t <<< received partial response: part \(partNo) >>>")
                                }

                                if !isMultiLine {
                                    completion(data)
                                    return
                                }

                                // here, we know we are dealing with a multi-line response.
                                self.dataBuffer?.append(data)

                                var isFinished = false
                                guard let dataBuffer = self.dataBuffer else {
                                    return
                                }
                                if dataBuffer.count >= 5 {
                                    let subData = dataBuffer[dataBuffer.count - 5 ..< dataBuffer.count]
                                    let terminatingString = String(data: subData, encoding: .utf8)
                                    if terminatingString == "\r\n.\r\n" {
                                        isFinished = true
                                    }
                                }

                                if isFinished {
                                    completion(self.dataBuffer)
                                } else {
                                    self.bufferData(partNo: (partNo + 1), completion: completion)
                                }
        }
    }
}
