//
//  Agent.swift
//  Agent
//
//  Created by Christoffer Hallas on 6/2/14.
//  Copyright (c) 2014 Christoffer Hallas. All rights reserved.
//

import Foundation

public class Agent {

  public typealias Headers = Dictionary<String, String>
  public typealias Response = (AnyObject?, URLResponse?, NSError?) -> Void
  public typealias RawResponse = (Data?, URLResponse?, NSError?) -> Void

  /**
   * Members
   */

  var base: NSURL?
  var headers: Dictionary<String, String>?
  var request: NSMutableURLRequest?
  let queue = OperationQueue()

  /**
   * Initialize
   */
  
  init(url: String, headers: Dictionary<String, String>?) {
    self.base = NSURL(string: url)
    self.headers = headers
  }
  
  convenience init(url: String) {
    self.init(url: url, headers: nil)
  }

  init(method: String, url: String, headers: Dictionary<String, String>?) {
    self.headers = headers
    _ = self.request(method: method, path: url)
  }
  
  convenience init(method: String, url: String) {
    self.init(method: method, url: url, headers: nil)
  }
  
  /**
   * Request
   */
  
  func request(method: String, path: String) -> Agent {
    var u: NSURL
    if self.base != nil {
      u = self.base!.appendingPathComponent(path)!
    } else {
      u = NSURL(string: path)!
    }

    self.request = NSMutableURLRequest(url: u as URL)
    self.request!.httpMethod = method
    
    if self.headers != nil {
      self.request!.allHTTPHeaderFields = self.headers
    }
    
    return self
  }

  /**
   * GET
   */

  public class func get(url: String) -> Agent {
    return Agent(method: "GET", url: url, headers: nil)
  }

  public class func get(url: String, headers: Headers) -> Agent {
    return Agent(method: "GET", url: url, headers: headers)
  }

  public class func get(url: String, done: Response) -> Agent {
    return Agent.get(url: url).end(done: done)
  }

  public class func get(url: String, headers: Headers, done: Response) -> Agent {
    return Agent.get(url: url, headers: headers).end(done: done)
  }
  
  public func get(url: String, done: Response) -> Agent {
    return self.request(method: "GET", path: url).end(done: done)
  }

  /**
   * POST
   */

  public class func post(url: String) -> Agent {
    return Agent(method: "POST", url: url, headers: nil)
  }

  public class func post(url: String, headers: Headers) -> Agent {
    return Agent(method: "POST", url: url, headers: headers)
  }

  public class func post(url: String, done: Response) -> Agent {
    return Agent.post(url: url).end(done: done)
  }

  public class func post(url: String, headers: Headers, data: AnyObject) -> Agent {
    return Agent.post(url: url, headers: headers).send(data: data)
  }

  public class func post(url: String, data: AnyObject) -> Agent {
    return Agent.post(url: url).send(data: data)
  }

  public class func post(url: String, data: AnyObject, done: Response) -> Agent {
    return Agent.post(url: url, data: data).send(data: data).end(done: done)
  }

  public class func post(url: String, headers: Headers, data: AnyObject, done: Response) -> Agent {
    return Agent.post(url: url, headers: headers, data: data).send(data: data).end(done: done)
  }

  public func POST(url: String, data: AnyObject, done: Response) -> Agent {
    return self.request(method: "POST", path: url).send(data: data).end(done: done)
  }

  /**
   * PUT
   */

  public class func put(url: String) -> Agent {
    return Agent(method: "PUT", url: url, headers: nil)
  }

  public class func put(url: String, headers: Headers) -> Agent {
    return Agent(method: "PUT", url: url, headers: headers)
  }

  public class func put(url: String, done: Response) -> Agent {
    return Agent.put(url: url).end(done: done)
  }

  public class func put(url: String, headers: Headers, data: AnyObject) -> Agent {
    return Agent.put(url: url, headers: headers).send(data: data)
  }

  public class func put(url: String, data: AnyObject) -> Agent {
    return Agent.put(url: url).send(data: data)
  }

  public class func put(url: String, data: AnyObject, done: Response) -> Agent {
    return Agent.put(url: url, data: data).send(data: data).end(done: done)
  }

  public class func put(url: String, headers: Headers, data: AnyObject, done: Response) -> Agent {
    return Agent.put(url: url, headers: headers, data: data).send(data: data).end(done: done)
  }
  
  public func PUT(url: String, data: AnyObject, done: Response) -> Agent {
    return self.request(method: "PUT", path: url).send(data: data).end(done: done)
  }

  /**
   * DELETE
   */

  public class func delete(url: String) -> Agent {
    return Agent(method: "DELETE", url: url, headers: nil)
  }

  public class func delete(url: String, headers: Headers) -> Agent {
    return Agent(method: "DELETE", url: url, headers: headers)
  }

  public class func delete(url: String, done: Response) -> Agent {
    return Agent.delete(url: url).end(done: done)
  }

  public class func delete(url: String, headers: Headers, done: Response) -> Agent {
    return Agent.delete(url: url, headers: headers).end(done: done)
  }

  public func delete(url: String, done: Response) -> Agent {
    return self.request(method: "DELETE", path: url).end(done: done)
  }

  /**
   * Methods
   */

  public func data(data: NSData?, mime: String) -> Agent {
    _ = self.set(header:"Content-Type", value: mime)
    self.request!.httpBody = data as? Data
    return self
  }
  
  public func send(data: AnyObject) -> Agent {
    let json = try! JSONSerialization.data(withJSONObject: data, options: [])
    return self.data(data: json, mime: "application/json")
  }

  public func set(header: String, value: String) -> Agent {
    self.request!.setValue(value, forHTTPHeaderField: header)
    return self
  }

  public func end(done: Response) -> Agent {
    let completion = { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
      if error != .none {
        done(data, .none, error)
        return
      }

      var json: AnyObject!
      if data != .none {
        json = try? JSONSerialization.data(withJSONObject: data!)
      }
      let res = response as! HTTPURLResponse
      done(json, res, nil)
    }
    let task =  URLSession.shared().dataTask(with:self.request! as URLRequest, completionHandler:completion)
    task.resume()
    return self
  }
  
  public func raw(done: RawResponse) -> Agent {
    let completion = { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
      if error != .none {
        done(data, .none, error)
        return
      }
      done(data, response as? HTTPURLResponse, error)
    }
    let task =  URLSession.shared().dataTask(with:self.request! as URLRequest, completionHandler:completion)
    task.resume()
    return self
  }
    
    public func json(done:Response) -> Agent {
        let completion = { (data:Data?, response:URLResponse?, error:NSError?) -> Void in
            if error != .none {
                done(data, .none, error)
                return
            }
            var json: AnyObject!
            
            if data != .none {
                json = try? JSONSerialization.jsonObject(with: data!)
            }
            let res = response as! HTTPURLResponse
            done(json, res, nil)
        }
        let task =  URLSession.shared().dataTask(with:self.request! as URLRequest, completionHandler:completion)
        task.resume()
        return self
    }

}
