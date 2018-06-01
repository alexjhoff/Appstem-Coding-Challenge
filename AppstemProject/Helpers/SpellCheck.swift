//
//  SpellCheck.swift
//  AppstemProject
//
//  Created by Alex Hoff on 5/31/18.
//

import Foundation

struct SpellCheck {
    var knownWords: [String:Int] = [:]
    
    // Function to add known words to knownWords dictionary
    // Adds weight to words that occur more
    mutating func train(word: String) {
        if let words = knownWords[word] {
            knownWords[word] = words + 1
        } else {
            knownWords[word] = 1
        }
    }
    
    // Initialize SpellCheck with known words text file
    init(contentsOfFile file: String) {
        var words: [String] = []
        file.enumerateLines { line, _ in
            words.append(line)
        }
        for word in words { self.train(word: word) }
    }
    
    // Builds all possible words from given word
    func edits(_ alphaWord: String) -> Set<String> {
        let vowel: [Character] = ["a","e","i","o","u"]
        // Breaks up word by all possible splits from their vowel
        let splits = alphaWord.indices.map {
            (alphaWord[alphaWord.startIndex..<$0], alphaWord[$0..<alphaWord.endIndex])
            }.filter { vowel.contains($0.1.first!) }
        
        // Replaces split words with all possible vowels
        let replaces = Set(splits.flatMap { word in
            vowel.map { "\(word.0)\($0)\(word.1.dropFirst())" }
        })
        return replaces
    }
    
    // Checks if one of the possible words is known
    func known<S: Sequence>(words: S) -> Set<String>? where S.Iterator.Element == String {
        let s = Set(words.filter { self.knownWords.index(forKey:$0) != nil })
        return s.isEmpty ? nil : s
    }
    
    // Checks if we can find a known word from spliting the given word twice
    func knownEdits2(word: String) -> Set<String>? {
        var known_edits: Set<String> = []
        for edit in edits(word) {
            if let k = known(words: edits(edit)) {
                known_edits = known_edits.union(k)
            }
        }
        return known_edits.isEmpty ? nil : known_edits
    }
    
    // Main function to remove non letter characters then check to find the correct word
    func correct(word: String) -> String {
        let alphaWord = word.replacingOccurrences(of: "[^A-z]", with: "", options: .regularExpression)
        
        // If one of the three functions returns a word then that is our answer
        let candidates = known(words: [alphaWord]) ?? known(words: edits(alphaWord)) ?? knownEdits2(word: alphaWord)
        guard let finalWord = candidates?.first else { return word }
        return finalWord
    }
}

