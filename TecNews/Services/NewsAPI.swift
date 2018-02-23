/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

class NewsAPI: NSObject {
  
  static let service = NewsAPI()
  
  private struct Response: Codable {
    let sources: [Source]?
    let articles: [Article]?
  }
  
  private enum API {
    private static let basePath = "https://newsapi.org/v2"
    private static let key = "3bbc0a09024f445ba0aff135bebe1434"
    
    case sources
    case articles(Source,String)
    
    func fetch(completion: @escaping (Data) -> ()) {
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: path()) { (data, response, error) in
        guard let data = data, error == nil else { return }
        completion(data)
      }
      task.resume()
    }
    
    private func path() -> URL {
      switch self {
      case .sources:
        return URL(string: "\(API.basePath)/sources?language=\(NSLocalizedString("language", comment: "Localized kind: Language"))&apiKey=\(API.key)")!
      case .articles(let source, let query):
        return URL(string: "\(API.basePath)/everything?sources=\(source.id)&q=\(query)&pageSize=100&sortBy=publishedAt&apiKey=\(API.key)")!
      }
    }
  }
  
  @objc dynamic private(set) var sources: [Source] = []
  @objc dynamic private(set) var articles: [Article] = []
  
  func fetchSources() {
    API.sources.fetch { data in
      if let sources = try! JSONDecoder().decode(Response.self, from: data).sources {
        self.sources = sources
      }
    }
  }
  
    func fetchArticles(for source: Source, with query:String = "") {
        let formatter = ISO8601DateFormatter()
        let customDateHandler: (Decoder) throws -> Date = { decoder in
          var string = try decoder.singleValueContainer().decode(String.self)
          string.deleteMillisecondsIfPresent()
          guard let date = formatter.date(from: string) else { return Date() }
          return date
        }
        API.articles(source,query).fetch { data in
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .custom(customDateHandler)
          if let articles = try! decoder.decode(Response.self, from: data).articles {
            self.articles = articles
          }
        }
  }
  
  func resetArticles() {
    articles = []
  }
}
