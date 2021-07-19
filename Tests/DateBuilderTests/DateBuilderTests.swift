#if !os(watchOS)
import XCTest
@testable import DateBuilder

final class DateBuilderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        twitter()
        
        let normalDelays = DelayDistribution.normal.generate(count: 100, start: 0, addDelay: { $0 + $1 })
        print("DELAYS", normalDelays)
        
        let optimisedDelays = DelayDistribution.optimized.generate(count: 100, start: 0, addDelay: { $0 + $1 })
        print("DELAYS", optimisedDelays)
    }
    
    override func tearDown() {
        super.tearDown()
        DateBuilder.calendar = .current
    }
    
    func testToday() {
        let dc = Today()
            .at(hour: 10, minute: 15)
            .dateComponents()
        let st = DateBuilder.Day.today.at(.time(hour: 10, minute: 15)).dateComponents()
        
        let actual = Date()._makeComponents()
        
        for today in [dc, st] {
            XCTAssertEqual(today.day, actual.day)
            XCTAssertEqual(today.month, actual.month)
            XCTAssertEqual(today.year, actual.year)
            XCTAssertEqual(today.hour, 10)
            XCTAssertEqual(today.minute, 15)
            XCTAssertEqual(today.second, 0)
        }
    }
    
    func testTomorrow() {
        let dc = Tomorrow()
            .at(hour: 14, minute: 30, second: 30)
            .dateComponents()
        let st = DateBuilder.Day.tomorrow.at(.time(hour: 14, minute: 30, second: 30)).dateComponents()
        
        let actual = Calendar.current.date(byAdding: .day, value: 1, to: Date())!._makeComponents()
        
        for tomorrow in [dc, st] {
            XCTAssertEqual(tomorrow.day, actual.day)
            XCTAssertEqual(tomorrow.month, actual.month)
            XCTAssertEqual(tomorrow.year, actual.year)
            XCTAssertEqual(tomorrow.hour, 14)
            XCTAssertEqual(tomorrow.minute, 30)
            XCTAssertEqual(tomorrow.second, 30)
        }
    }
    
    func testDayOf() {
        let randomDate = Date().addingTimeInterval(.random(in: 1 ... 5000) * 360 * 600)
        let dc = DayOf(randomDate).at(hour: 18, minute: 11).dateComponents()
        let st = DateBuilder.Day.dayOf(randomDate).at(hour: 18, minute: 11, second: 00).dateComponents()
        
        let actual = randomDate._makeComponents()
        
        for gen in [dc, st] {
            XCTAssertEqual(gen.day, actual.day)
            XCTAssertEqual(gen.month, actual.month)
            XCTAssertEqual(gen.year, actual.year)
            XCTAssertEqual(gen.hour, 18)
            XCTAssertEqual(gen.minute, 11)
            XCTAssertEqual(gen.second, 00)
        }
    }
    
    func testExactDay() {
        let dc = ExactDay(year: 2019, month: 10, day: 17).dateComponents()
        for gen in [dc] {
            XCTAssertEqual(gen.day, 17)
            XCTAssertEqual(gen.month, 10)
            XCTAssertEqual(gen.year, 2019)
        }
    }
    
    func testChangingCalendar() {
        var modified = Calendar.current
        let startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(startOfNextWeek)
        modified.firstWeekday = 4
        DateBuilder.calendar = modified
        let _startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(_startOfNextWeek)
        XCTAssertNotEqual(startOfNextWeek, _startOfNextWeek)
        DateBuilder.calendar = .current
        let againStartOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(againStartOfNextWeek)
        XCTAssertEqual(startOfNextWeek, againStartOfNextWeek)
    }
    
    func testWithCalendar() {
        var current = Calendar.current
        let startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(startOfNextWeek)
        current.firstWeekday = 4
        DateBuilder.withCalendar(current) {
            let _startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
            print(_startOfNextWeek)
            XCTAssertNotEqual(startOfNextWeek, _startOfNextWeek)
        }
        let againStartOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(againStartOfNextWeek)
        XCTAssertEqual(startOfNextWeek, againStartOfNextWeek)
    }
    
    func testWithTimeZone() {
        var current = Calendar.current
        current.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        DateBuilder.calendar = current
        let tomorrowMorning = Tomorrow().at(hour: 9, minute: 00).date()
        print(tomorrowMorning)
        DateBuilder.withTimeZone(TimeZone(identifier: "Europe/Moscow")!) {
            print(DateBuilder.calendar.timeZone)
            let _tomorrowMorning = Tomorrow().at(hour: 9, minute: 00).date()
            print(_tomorrowMorning)
            XCTAssertNotEqual(tomorrowMorning.timeIntervalSince1970, _tomorrowMorning.timeIntervalSince1970)
        }
        let againTomorrowMorning = Tomorrow().at(hour: 9, minute: 00).date()
        print(againTomorrowMorning)
        XCTAssertEqual(tomorrowMorning, againTomorrowMorning)
        DateBuilder.calendar = .current
    }
    
    func testWithLocale() {
        var current = Calendar.current
        current.locale = Locale(identifier: "en_US")
        DateBuilder.calendar = current
        let startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(startOfNextWeek)
        DateBuilder.withLocale(Locale(identifier: "ru_RU")) {
            let _startOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
            print(_startOfNextWeek)
            XCTAssertNotEqual(startOfNextWeek, _startOfNextWeek)
        }
        let againStartOfNextWeek = NextWeek().firstDay.at(hour: 10, minute: 15).date()
        print(againStartOfNextWeek)
        XCTAssertEqual(startOfNextWeek, againStartOfNextWeek)
        DateBuilder.calendar = .current
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

extension Date {
    func _makeComponents() -> DateComponents {
        return Calendar.current.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear, .yearForWeekOfYear], from: self)
    }
}

extension DateComponents {
    func _makeDate() -> Date {
        var copy = self
        copy.calendar = .current
        return copy.date!
    }
}

struct Account {
    let createdAt: Date = .init()
}

let account = Account()

func readme() {
    
ExactlyAt(account.createdAt)
    .addingMinutes(1)
    .dateComponents()
    
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
    
let tomorrowMorning = DateBuilder.withTimeZone(TimeZone(identifier: "America/Cancun")!) {
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
    
EveryWeek(forWeeks: 50, starting: .thisWeek)
    .firstDay
    .at(hour: 10, minute: 00)
    .dateComponents()
    
EveryMonth(forMonths: 12, starting: .thisMonth)
    .first(.friday)
    .at(hour: 20, minute: 15)
    .dates()
    
let dates = EveryMonth(forMonths: 12, starting: .thisMonth)
    .firstDay.addingDays(9)
    .at(hour: 20, minute: 00)
    .dates() // [Date]
}
#endif
