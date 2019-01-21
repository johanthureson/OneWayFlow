// This file needs no changes

import Foundation

protocol StateUpdatable {
    func updateState(to newState: StateStruct) -> ()
}

class ActionClassParent {
    
    // the state is by default not saved and loaded from disk
    var persistState = false
    
    // Init with default state
    // It is possible to inject a state.
    // That is very useful in at least two cases:
    // 1) Inject a state with test case when unit testing
    // 2) Inject the saved state, when persisting (which is done automatically if persistState is set to true)
    init(state: StateStruct = StateStruct(), persistState: Bool = false) {
        self.state = state
        self.persistState = persistState
    }
    
    // call updsteState, when the state is changed
    private let backgroundSyncronizeSharedDataQueue = DispatchQueue(label: "backgroundSyncronizeSharedData")
    private var syncedStateSource: StateStruct!
    internal var state: StateStruct! {
        set(newValue) {
            backgroundSyncronizeSharedDataQueue.sync {
                if syncedStateSource == newValue { return }
                self.syncedStateSource = newValue
                stateUpdatableSubscribersArray = stateUpdatableSubscribersArray.filter { $0 as? NSObject != nil }
                DispatchQueue.main.async() {
                    self.stateUpdatableSubscribersArray.forEach {
                        $0.updateState(to: self.state)
                    }
                }
                if persistState {
                    do {
                        try Persistance.save(newValue)
                    } catch {
                        print("Could not write to disk")
                    }
                }
            }
        }
        get {
            return backgroundSyncronizeSharedDataQueue.sync {
                syncedStateSource
            }
        }
    }
    
    // subscriptions
    private var stateUpdatableSubscribersArray = [StateUpdatable]()
    
    // subscribe
    open func subscribe(_ subscriber: StateUpdatable) {
        // remove all examples of subscriber already in the array
        if let index = stateUpdatableSubscribersArray.index(where: {$0 as! NSObject === subscriber as! NSObject}) {
            stateUpdatableSubscribersArray.remove(at: index)
        }
        // add the subscriber
        stateUpdatableSubscribersArray.append(subscriber)
        // always send the state when a subscriber subscribes
        DispatchQueue.main.async() {
            subscriber.updateState(to: self.state)
        }
    }
    
    // unsubscribe
    open func unsubscribe(_ subscriber: StateUpdatable) {
        // remove all examples of subscriber already in the array
        if let index = stateUpdatableSubscribersArray.index(where: {$0 as! NSObject === subscriber as! NSObject}) {
            stateUpdatableSubscribersArray.remove(at: index)
        }
    }
    
}



class Persistance {
    
    static func save(_ value: StateStruct, encoder: JSONEncoder = JSONEncoder()) throws {
        do {
            let url = try createURL(for: "StateStruct.json", in: "<Application_Home>/Documents")
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }
    
    static func createURL(for validPath: String, in directory: String) throws -> URL {
        let filePrefix = "file://"
        let searchPathDirectory: FileManager.SearchPathDirectory = .documentDirectory
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent(validPath, isDirectory: false)
            if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                let fixedUrlString = filePrefix + url.absoluteString
                url = URL(string: fixedUrlString)!
            }
            return url
        } else {
            throw createError(
                .couldNotAccessUserDomainMask,
                description: "Could not create URL for \(directory)/\(validPath)",
                failureReason: "Could not get access to the file system's user domain mask.",
                recoverySuggestion: "Use a different directory."
            )
        }
    }
    
    public static let errorDomain = "DiskErrorDomain"
    
    static func createError(_ errorCode: ErrorCode, description: String?, failureReason: String?, recoverySuggestion: String?) -> Error {
        let errorInfo: [String: Any] = [NSLocalizedDescriptionKey : description ?? "",
                                        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
                                        NSLocalizedFailureReasonErrorKey: failureReason ?? ""]
        return NSError(domain: errorDomain, code: errorCode.rawValue, userInfo: errorInfo) as Error
    }
    
    enum ErrorCode: Int {
        case noFileFound = 0
        case couldNotAccessUserDomainMask = 5
    }
    
    static func load() throws -> StateStruct {
        let path = "StateStruct.json"
        let directory = "<Application_Home>/Documents"
        let decoder = JSONDecoder()
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let data = try Data(contentsOf: url)
            let value = try decoder.decode(StateStruct.self, from: data)
            return value
        } catch {
            throw error
        }
    }
    
    static func getExistingFileURL(for path: String, in directory: String) throws -> URL {
        do {
            let url = try createURL(for: path, in: directory)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
            throw createError(
                .noFileFound,
                description: "Could not find an existing file or folder at \(url.path).",
                failureReason: "There is no existing file or folder at \(url.path)",
                recoverySuggestion: "Check if a file or folder exists before trying to commit an operation on it."
            )
        } catch {
            throw error
        }
    }
    
}

/*
 https://github.com/johanthureson/OneWayFlow
 
 MIT License
 
 Copyright (c) 2019 johanthureson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
