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

let account = Account()

func readme() {
    Today()
        .addingDays(10)
    Tomorrow()
    DayOf(account.createdAt)
    ExactDay(year: 2021, month: 1, day: 26)
    AddingDays(15, to: .today)
    AddingDays(15, to: .dayOf(account.createdAt))
    EveryDay(forDays: 100, starting: .tomorrow)
    EveryDay(forDays: 100, starting: .dayOf(account.createdAt))
    
ThisWeek()
NextWeek()
WeekOf(account.createdAt)
WeekOf(Today()) // use any `DateBuilder.Day` instance here
AddingWeeks(5, to: .thisWeek)
EveryWeek(forWeeks: 10, starting: .nextWeek)
    
    ThisWeek()
        .addingWeeks(10)
    
ThisMonth()
NextMonth()
MonthOf(account.createdAt)
MonthOf(Today()) // use any `DateBuilder.Day` instance here
    ExactMonth(year: 2021, month: 03)
AddingMonths(3, to: .thisMonth)
EveryMonth(forMonths: 5, starting: .monthOf(account.createdAt))
    
ThisMonth().addingMonths(5)
ThisMonth().firstDay
ThisMonth().lastDay
ThisMonth().allDays
ThisMonth().first(.saturday)
ThisMonth().weekday(.third, .friday)
    
ThisYear()
NextYear()
YearOf(account.createdAt)
YearOf(Tomorrow()) // use any `DateBuilder.Day` instance here
YearOf(NextMonth()) // use any `DateBuilder.Month` instance here
ExactYear(year: 2022)
AddingYears(1, to: ThisYear())
EveryYear(forYears: 100, starting: .thisYear)
    
    ThisYear().addingYears(1)
    ThisYear().firstMonth
    ThisYear().lastMonth
    ThisYear().allMonths
    
    Today().at(hour: 10, minute: 15)
    Today().at(hour: 19, minute: 30, second: 30)
    Today().at(TimeOfDay(hour: 10, minute: 30, second: 0)) // equivalent to:
    Today().at(.time(hour: 10, minute: 30))
    Today().at(.randomTime(from: .time(hour: 10, minute: 15), to: .time(hour: 15, minute: 30)))
    
    var customCalendar = DateBuilder.calendar
    customCalendar.firstWeekday = 6
    DateBuilder.calendar = customCalendar
    
DateBuilder.withCalendar(customCalendar) {
    ThisWeek().firstDay.dateComponents()
}
    
let tomorrowMorning = DateBuilder.withTimeZone(TimeZone(identifier: "America/Cancun")) {
    return Tomorrow().at(hour: 9, minute: 15).date()
}
    
DateBuilder.withLocale(Locale(identifier: "he_IL")) {
    NextWeek()
        .weekendStartDay
        .at(hour: 7, minute: 00)
        .date() // next friday!
}
}

func readme2() {
NextYear()
    .firstMonth.addingMonths(3)
    .first(.thursday)
    .dateComponents()
}

func twitter() {
    
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
    
let dates = EveryMonth(forMonths: 12, starting: .thisMonth)
    .firstDay.addingDays(9)
    .at(hour: 20, minute: 00)
    .dates() // [Date]
}
#endif
