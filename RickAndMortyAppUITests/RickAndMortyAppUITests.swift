//
//  RickAndMortyAppUITests.swift
//  RickAndMortyAppUITests
//
//  Created by Paul Flores on 28/09/25.
//

import XCTest

final class RickAndMortyAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Full flow test
    func testSearchAndFavoriteFlow() throws {
        // 1. Navigate to Characters tab
        let charactersTab = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(charactersTab.exists)
        charactersTab.tap()

        // 2. Search for "Rick"
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Rick")
        app.keyboards.buttons["Search"].tap()
        
        // 3. Tap on first character cell
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()
        
        // 4. Mark as favorite
        let favoriteButton = app.buttons["favoriteButton_1"]
        XCTAssertTrue(favoriteButton.exists)
        favoriteButton.tap()
        
        // 5. Go to Favorites tab
        let favoritesTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(favoritesTab.exists)
        favoritesTab.tap()
        
        // 6. Validate "Rick" is now in favorites list
        let rickCell = app.staticTexts["Rick Sanchez"]
        XCTAssertTrue(rickCell.waitForExistence(timeout: 5))
    }
}
