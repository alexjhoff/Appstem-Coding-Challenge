//
//  AppstemProjectTests.swift
//  AppstemProjectTests
//
//  Created by Alex Hoff on 5/29/18.
//

import XCTest
@testable import AppstemProject

class AppstemProjectTests: XCTestCase {
    
    fileprivate var request: ApiRequest?
    fileprivate var checker: SpellCheck?
    
    override func setUp() {
        super.setUp()
        
        if  let fileUrl = Bundle.main.path(forResource: "google-10000-english-no-swears", ofType: "txt") {
            do {
                let data = try String(contentsOf: URL(fileURLWithPath: fileUrl))
                checker = SpellCheck(contentsOfFile: data)
            } catch {
                print("Error fetching word dictionary")
            }
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRepoUrlBuilt() {
        // Given
        let targetUrl = URL(string: "https://api.gettyimages.com/v3/search/images?fields=id,title,thumb,referral_destinations&sort_order=best&phrase=cat")
        
        // When
        let testRequest = URLRequest.buildUrlWithPhrase("cat")
        let testUrl = testRequest.url
        
        // Then
        XCTAssertEqual(testUrl, targetUrl, "URL was not built correctly")
    }
    
    func testAPICallCompletes() {
        // Given
        guard let testUrl = URL(string: "https://api.gettyimages.com/v3/search/images?fields=id,title,thumb,referral_destinations&sort_order=best&phrase=cat") else { return }
        let testRequest = URLRequest(url: testUrl)
        let session = MockSession()
        let promise = expectation(description: "Download github repo data")
        
        // When
        request = ApiRequest(url: testRequest, session: session)
        request?.load { (session: Session?) in
            //Make sure data was downloaded
            XCTAssertNotNil(session, "No session data downloaded")
            
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
    }
    
    func testSpellCheck() {
        guard let checker = checker else { return }
        
        let word1 = "be3ak"
        let checkedWord1 = checker.correct(word: word1)
        XCTAssert(checkedWord1 == "book", "Word 1 check error")
        
        let word2 = "nyl;on"
        let checkedWord2 = checker.correct(word: word2)
        XCTAssert(checkedWord2 == "nylon", "Word 2 check error")
        
        let word3 = "ceku"
        let checkedWord3 = checker.correct(word: word3)
        XCTAssert(checkedWord3 == "cake", "Word 3 check error")
    }
}
