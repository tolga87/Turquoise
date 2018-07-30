//
//  GroupListManager.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class GroupListManager {
    let usenetClient: UsenetClientInterface

    init(usenetClient: UsenetClientInterface) {
        self.usenetClient = usenetClient
    }

    func downloadGroupList(completion: (([GroupInfo]?) -> Void)?) {
        let request = NNTPRequest(string: "LIST\r\n")
        self.usenetClient.makeRequest(request) { (response) in
            guard let response = response as? NNTPMultiLineResponse, response.ok() else {
                completion?(nil)
                return
            }

            let groupInfos: [GroupInfo] = response.lines.compactMap { line in
                let components = line.components(separatedBy: .whitespaces)
                guard components.count >= 4 else {
                    return nil
                }

                return GroupInfo(groupId: components[0],
                                 highestArticleNo: components[1],
                                 lowestArticleNo: components[2],
                                 flags: components[3])
            }

            completion?(groupInfos)
        }
    }
}
