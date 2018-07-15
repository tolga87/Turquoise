//
//  GroupViewModel.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

protocol GroupViewModelInterface {

    func numberOfArticles() -> Int

    func titleForArticleAtIndex(_ index: Int) -> String

    func authorForArticleAtIndex(_ index: Int) -> String
}

class GroupViewModel : GroupViewModelInterface {
    var articles: [TQNNTPArticle]?

    func numberOfArticles() -> Int {
        return self.articles?.count ?? 0
    }

    func titleForArticleAtIndex(_ index: Int) -> String {
        return self.articles![index].subject
    }

    func authorForArticleAtIndex(_ index: Int) -> String {
        return self.articles![index].from
    }
}
