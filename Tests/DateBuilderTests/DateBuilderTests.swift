#if !os(watchOS)
import XCTest
@testable import DateBuilder

final class DateBuilderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        twitter()
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

struct Account {
    let createdAt: Date = .init()
}

func twitter() {
    let account = Account()
    
Today()
    .at(hour: 20, minute: 15)
    .dateComponents() // year: 2021, month: 1, day: 31, hour: 20, minute: 15

NextWeek()
    .weekday(.saturday)
    .at(hour: 18, minute: 50)
    .dateComponents() // DateComponents

EveryWeek(forWeeks: 10, starting: .thisWeek)
    .weekendStartDay
    .at(hour: 9, minute: 00)
    .dates() // [Date]
    
ExactlyAt(account.createdAt)
    .addingDays(15)
    .date() // Date
    
WeekOf(account.createdAt)
    .addingWeeks(1)
    .lastDay
    .at(hour: 10, minute: 00)
    .dateComponents() // DateComponents

EveryMonth(forMonths: 12, starting: .thisMonth)
    .lastDay
    .at(hour: 23, minute: 50)
    .dateComponents() // [DateComponents]

NextYear().addingYears(2)
    .firstMonth.addingMonths(3) // April (in Gregorian)
    .first(.thursday)
    .dateComponents() // year: 2024, month: 4, day: 4

ExactDay(year: 2020, month: 10, day: 5)
    .at(hour: 10, minute: 15)
    .date() // Date
    
ExactYear(year: 2020)
    .lastMonth
    .lastDay
    .dateComponents()
}
#endif
