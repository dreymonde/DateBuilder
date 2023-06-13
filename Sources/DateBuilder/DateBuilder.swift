import Foundation

public enum DateBuilder {
    private static var _calendar = { Calendar.current }
    public static var calendar: Calendar {
        get {
            return _calendar()
        }
        set {
            if newValue == Calendar.current {
                _calendar = { Calendar.current }
            } else {
                _calendar = { newValue }
            }
        }
    }
    
    public static func withCalendar<T>(_ calendar: Calendar, _ perform: () -> T) -> T {
        let backup = _calendar
        _calendar = { calendar }
        let returnValue = perform()
        _calendar = backup
        return returnValue
    }
    
    public static func withTimeZone<T>(_ timeZone: TimeZone, _ perform: () -> T) -> T {
        var current = calendar
        current.timeZone = timeZone
        return withCalendar(current, perform)
    }
    
    public static func withLocale<T>(_ locale: Locale, _ perform: () -> T) -> T {
        var current = calendar
        current.locale = locale
        return withCalendar(current, perform)
    }
}

public struct TimeOfDay: Codable, Hashable, Comparable {
    public var hour: Int
    public var minute: Int
    public var second: Int = 0
    
    public init(hour: Int, minute: Int, second: Int = 0) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }
    
    public static func time(hour: Int, minute: Int, second: Int = 0) -> TimeOfDay {
        return TimeOfDay(hour: hour, minute: minute, second: second)
    }
    
    public static func randomTime(from lower: TimeOfDay, to upper: TimeOfDay) -> TimeOfDay {
        let reference = Date()
        let calendar = DateBuilder.calendar
        let lowerDate = calendar.date(bySettingHour: lower.hour, minute: lower.minute, second: lower.second, of: reference)!
        let upperDate = calendar.date(bySettingHour: upper.hour, minute: upper.minute, second: upper.second, of: reference)!
        assert(lowerDate < upperDate, "make sure 'from' is before 'to'")
        let timeIntervalDif = Int(upperDate.timeIntervalSince(lowerDate))
        let randomTimeDiff = Int.random(in: 0 ..< timeIntervalDif)
        let randomDate = lowerDate.addingTimeInterval(TimeInterval(randomTimeDiff))
        let timeOfDay = TimeOfDay(date: randomDate, calendar: calendar)
        return timeOfDay
    }
    
    public static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
        guard lhs.hour == rhs.hour else {
            return lhs.hour < rhs.hour
        }
        
        guard lhs.minute == rhs.minute else {
            return lhs.minute < rhs.minute
        }
        
        return lhs.second < rhs.second
    }
}

extension TimeOfDay {
    public init(date: Date, calendar: Calendar = DateBuilder.calendar) {
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        self.init(hour: components.hour ?? 0, minute: components.minute ?? 0, second: components.second ?? 0)
    }
}

extension DateBuilder {
    public enum ResolvedDate {
        case exact(Foundation.Date)
        case components(DateComponents)
        
        public func dateComponents() -> DateComponents {
            switch self {
            case .exact(let date):
                let components = DateBuilder.calendar.dateComponents([.era, .year, .month, .weekday, .day, .hour, .minute, .second], from: date)
                return components
            case .components(let components):
                return components
            }
        }
        
        public func date() -> Date {
            switch self {
            case .exact(let date):
                return date
            case .components(let components):
                if let date = DateBuilder.calendar.date(from: components) {
                    return date
                } else {
                    print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                    assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                    return .distantPast
                }
            }
        }
        
        public func adding(dateComponents: DateComponents) -> ResolvedDate? {
            let added = DateBuilder.calendar.date(byAdding: dateComponents, to: date())
            return added.map(ResolvedDate.exact)
        }
        
        public func addingSeconds(_ seconds: Int) -> ResolvedDate {
            let components = DateComponents(second: seconds)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingMinutes(_ minutes: Int) -> ResolvedDate {
            let components = DateComponents(minute: minutes)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingHours(_ hours: Int) -> ResolvedDate {
            let components = DateComponents(hour: hours)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingDays(_ days: Int) -> ResolvedDate {
            let components = DateComponents(day: days)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingWeeks(_ weeks: Int) -> ResolvedDate {
            let components = DateComponents(weekOfYear: weeks)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingMonths(_ months: Int) -> ResolvedDate {
            let components = DateComponents(month: months)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
        
        public func addingYears(_ years: Int) -> ResolvedDate {
            let components = DateComponents(year: years)
            if let date = adding(dateComponents: components) {
                return date
            } else {
                print("UNEXPECTED - INVALID COMPONENTS: \(components)")
                assertionFailure("UNEXPECTED - INVALID COMPONENTS: \(components)")
                return .exact(.distantPast)
            }
        }
    }
    
    public struct Day {
        var base: Date
        var offset: Int
        
        public static var today: Day { Today() }
        
        public static func dayOf(_ date: Date) -> Day {
            return DayOf(date)
        }
        
        public static var tomorrow: Day { Tomorrow() }
        
        fileprivate func finalize() -> Date {
            return DateBuilder.calendar.date(byAdding: .day, value: offset, to: base) ?? .distantFuture
        }
        
        public func addingDays(_ days: Int) -> Day {
            return Day(base: base, offset: offset + days)
        }
        
        public func dateComponents() -> DateComponents {
            let components = finalize()._extract(components: [.era, .year, .month, .day])
            return components
        }
        
        public func at(_ timeOfDay: @autoclosure () -> TimeOfDay) -> ResolvedDate {
            let date = finalize()
            let timeOfDay = timeOfDay()
            let calendar = DateBuilder.calendar
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = timeOfDay.hour
            components.minute = timeOfDay.minute
            components.second = timeOfDay.second
            return .components(components)
        }
        
        public func at(hour: Int, minute: Int, second: Int = 0) -> ResolvedDate {
            return at(.init(hour: hour, minute: minute, second: second))
        }
    }
}

extension Sequence where Element == DateBuilder.ResolvedDate {
    public func dates() -> [Date] {
        return map({ $0.date() })
    }
    
    public func dateComponents() -> [DateComponents] {
        return map({ $0.dateComponents() })
    }
}

extension Sequence where Element == DateBuilder.Day {
    public func addingDays(_ days: Int) -> [DateBuilder.Day] {
        return map({ $0.addingDays(days) })
    }
    
    public func at(_ timeOfDay: @autoclosure () -> TimeOfDay) -> [DateBuilder.ResolvedDate] {
        return map { $0.at(timeOfDay()) }
    }
    
    public func at(hour: Int, minute: Int, second: Int = 0) -> [DateBuilder.ResolvedDate] {
        at(.init(hour: hour, minute: minute, second: second))
    }
    
    public func dateComponents() -> [DateComponents] {
        return map({ $0.dateComponents() })
    }
}

public func ExactDay(year: Int, month: Int, day: Int) -> DateBuilder.Day {
    let calendar = DateBuilder.calendar
    let components = DateComponents(year: year, month: month, day: day)
    let date = calendar.date(from: components) ?? .distantPast
    return .init(base: date.addingTimeInterval(5.0), offset: 0)
}

public func Today() -> DateBuilder.Day {
    return DayOf(Date())
}

public func Tomorrow() -> DateBuilder.Day {
    return Today().addingDays(1)
}

public func DayOf(_ date: Date) -> DateBuilder.Day {
    return .init(base: date, offset: 0)
}

public func AddingDays(_ days: Int, to day: DateBuilder.Day) -> DateBuilder.Day {
    return day.addingDays(days)
}

public func DayOf(_ date: Date, at timeOfDay: TimeOfDay) -> DateBuilder.ResolvedDate {
    return DayOf(date).at(timeOfDay)
}

public func Today(at timeOfDay: TimeOfDay) -> DateBuilder.ResolvedDate {
    let today = Date()
    return DayOf(today, at: timeOfDay)
}

public func Tomorrow(at timeOfDay: TimeOfDay) -> DateBuilder.ResolvedDate {
    return AfterToday(days: 1, at: timeOfDay)
}

public func AfterToday(days: Int, at timeOfDay: TimeOfDay) -> DateBuilder.ResolvedDate {
    let today = Date()
    return After(dayOf: today, days: days, at: timeOfDay)
}

public func After(dayOf date: Date, days: Int, at timeOfDay: TimeOfDay) -> DateBuilder.ResolvedDate {
    return AddingDays(days, to: .dayOf(date)).at(timeOfDay)
}

public struct DelayDistribution {
    public init(delayForNumber: @escaping (_ number: Int, _ totalCount: Int) -> Int) {
        self.delayForNumber = delayForNumber
    }
    
    public let delayForNumber: (_ number: Int, _ totalCount: Int) -> Int
    
    public static let normal = DelayDistribution(delayForNumber: { number, _ in number })
    
    public static let optimized = DelayDistribution { number, totalCount in
        let breakpoint = totalCount / 2
        if number <= breakpoint {
            return number
        } else {
            let shift = number - breakpoint
            let exponent = shift * shift
            return number + exponent
        }
    }
    
    public func generate<Unit>(count: Int, start: Unit, addDelay: (Unit, Int) -> Unit) -> [Unit] {
        precondition(count >= 0)
        return (0 ..< count)
            .lazy
            .map({ self.delayForNumber($0, Int(count)) })
            .map({ addDelay(start, $0) })
    }
}

public func EveryDay(forDays nextDays: Int, starting startDay: DateBuilder.Day, distribution: DelayDistribution = .normal) -> [DateBuilder.Day] {
    return distribution.generate(count: nextDays, start: startDay, addDelay: { $0.addingDays($1) })
}

public func EveryDay(starting day: DateBuilder.Day, forDays days: Int, at timeOfDay: @autoclosure () -> TimeOfDay) -> [DateBuilder.ResolvedDate] {
    return EveryDay(forDays: days, starting: day).at(timeOfDay())
}

extension DateBuilder {
    public struct Week {
        var base: (yearForWeekOfYear: Int, weekOfYear: Int)
        var offset: Int
        
        public static var thisWeek: Week {
            return weekOf(Date())
        }
        
        public static var nextWeek: Week {
            return thisWeek.addingWeeks(1)
        }
        
        public static func weekOf(_ date: Date) -> Week {
            return Week(base: (yearForWeekOfYear: date._extract(.yearForWeekOfYear), weekOfYear: date._extract(.weekOfYear)), offset: 0)
        }
        
        private var baseDateComponents: DateComponents {
            return DateComponents(weekOfYear: base.weekOfYear, yearForWeekOfYear: base.yearForWeekOfYear)
        }
        
        fileprivate func finalize() -> Date {
            let base = DateBuilder.calendar.date(from: baseDateComponents) ?? .distantFuture
            return DateBuilder.calendar.date(byAdding: .weekOfYear, value: offset, to: base) ?? .distantFuture
        }
        
        public func addingWeeks(_ weeks: Int) -> Week {
            return Week(base: self.base, offset: self.offset + weeks)
        }
        
        public var firstDay: Day {
            return Day(base: finalize(), offset: 0)
        }
        
        public func weekday(_ weekday: GregorianWeekday) -> Day {
            let finalized = finalize()
            var components = DateBuilder.calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: finalized)
            components.weekday = weekday.rawValue
            let date = DateBuilder.calendar.date(from: components) ?? .distantFuture
            return DayOf(date)
        }
        
        public struct GregorianWeekday: ExpressibleByIntegerLiteral {
            public var rawValue: Int
            
            public static let sunday: GregorianWeekday = 1
            public static let monday: GregorianWeekday = 2
            public static let tuesday: GregorianWeekday = 3
            public static let wednesday: GregorianWeekday = 4
            public static let thursday: GregorianWeekday = 5
            public static let friday: GregorianWeekday = 6
            public static let saturday: GregorianWeekday = 7
            
            public typealias IntegerLiteralType = Int
            
            public init(rawValue: Int) {
                self.rawValue = rawValue
            }
            
            public init(integerLiteral value: Int) {
                self.rawValue = value
            }
        }
        
        public var weekendStartDay: Day {
            guard var weekend = DateBuilder.calendar.nextWeekend(startingAfter: finalize()) else {
                return lastDay
            }
            weekend.start.addTimeInterval(5)
            return DayOf(weekend.start)
        }
        
        public var weekendEndDay: Day {
            guard var weekend = DateBuilder.calendar.nextWeekend(startingAfter: finalize()) else {
                return lastDay
            }
            weekend.end.addTimeInterval(-5)
            return DayOf(weekend.end)
        }
        
        public var lastDay: Day {
            guard var interval = DateBuilder.calendar.dateInterval(of: .weekOfYear, for: finalize()) else {
                return firstDay
            }
            // otherwise the end of the interval will be midnight of the first day of next week
            interval.end.addTimeInterval(-5)
            return Day(base: interval.end, offset: 0)
        }
        
        public var allDays: [Day] {
            guard var interval = DateBuilder.calendar.dateInterval(of: .weekOfYear, for: finalize()) else {
                return []
            }
            interval.start.addTimeInterval(5)
            interval.end.addTimeInterval(-5)
            var current = interval.start
            var all: [Day] = []
            while interval.contains(current) {
                all.append(Day(base: current, offset: 0))
                current = DateBuilder.calendar.date(byAdding: .day, value: 1, to: current) ?? .distantFuture
            }
            return all
        }
    }
}

extension Sequence where Element == DateBuilder.Week {
    public func addingWeeks(_ weeks: Int) -> [DateBuilder.Week] {
        return map({ $0.addingWeeks(weeks) })
    }
    
    public var firstDay: [DateBuilder.Day] {
        return map(\.firstDay)
    }
    
    public var lastDay: [DateBuilder.Day] {
        return map(\.lastDay)
    }
    
    public func weekday(_ weekday: DateBuilder.Week.GregorianWeekday) -> [DateBuilder.Day] {
        return map({ $0.weekday(weekday) })
    }
    
    public var weekendStartDay: [DateBuilder.Day] {
        return map(\.weekendStartDay)
    }
    
    public var weekendEndDay: [DateBuilder.Day] {
        return map(\.weekendEndDay)
    }
}

public func ThisWeek() -> DateBuilder.Week {
    return .thisWeek
}

public func NextWeek() -> DateBuilder.Week {
    return .nextWeek
}

public func WeekOf(_ date: Date) -> DateBuilder.Week {
    return .weekOf(date)
}

public func WeekOf(_ day: DateBuilder.Day) -> DateBuilder.Week {
    return .weekOf(day.finalize())
}

public func AddingWeeks(_ weeks: Int, to week: DateBuilder.Week) -> DateBuilder.Week {
    return week.addingWeeks(weeks)
}

public func EveryWeek(forWeeks nextWeeks: Int, starting startWeek: DateBuilder.Week, distribution: DelayDistribution = .normal) -> [DateBuilder.Week] {
    return distribution.generate(count: nextWeeks, start: startWeek, addDelay: { $0.addingWeeks($1) })
}

extension DateBuilder {
    public struct Month {
        var base: (year: Int, month: Int)
        var offset: Int
        
        public static var thisMonth: Month {
            return monthOf(Date())
        }
        
        public static var nextMonth: Month {
            return thisMonth.addingMonths(1)
        }
        
        public static func monthOf(_ date: Date) -> Month {
            return Month(base: (year: date._extract(.year), month: date._extract(.month)), offset: 0)
        }
        
        private var baseDateComponents: DateComponents {
            return DateComponents(year: base.year, month: base.month)
        }
        
        fileprivate func finalize() -> Date {
            let base = DateBuilder.calendar.date(from: baseDateComponents) ?? .distantFuture
            return DateBuilder.calendar.date(byAdding: .month, value: offset, to: base) ?? .distantFuture
        }
        
        public func addingMonths(_ months: Int) -> Month {
            return Month(base: self.base, offset: offset + months)
        }
        
        public var firstDay: Day {
            return Day(base: finalize(), offset: 0)
        }
        
        public var lastDay: Day {
            guard var interval = DateBuilder.calendar.dateInterval(of: .month, for: finalize()) else {
                return firstDay
            }
            // otherwise the end of the interval will be midnight of the first day of next month
            interval.end.addTimeInterval(-5)
            return Day(base: interval.end, offset: 0)
        }
        
        public func weekday(_ ordinal: Ordinal, _ weekday: Week.GregorianWeekday) -> Day? {
            var components = DateBuilder.calendar.dateComponents([.year, .month], from: finalize())
            components.weekday = weekday.rawValue
            components.weekdayOrdinal = ordinal.rawValue
            let date = DateBuilder.calendar.date(from: components)
            return date.map(DayOf)
        }
        
        public func first(_ weekday: Week.GregorianWeekday) -> Day {
            return self.weekday(.first, weekday) ?? DayOf(.distantFuture)
        }
        
        public var allDays: [Day] {
            guard var interval = DateBuilder.calendar.dateInterval(of: .month, for: finalize()) else {
                return []
            }
            interval.start.addTimeInterval(5)
            interval.end.addTimeInterval(-5)
            var current = interval.start
            var all: [Day] = []
            while interval.contains(current) {
                all.append(Day(base: current, offset: 0))
                current = DateBuilder.calendar.date(byAdding: .day, value: 1, to: current) ?? .distantFuture
            }
            return all
        }
    }
    
    public struct Ordinal {
        public var rawValue: Int
        
        public static let first = Ordinal(rawValue: 1)
        public static let second = Ordinal(rawValue: 2)
        public static let third = Ordinal(rawValue: 3)
        public static let fourth = Ordinal(rawValue: 4)
        public static let fifth = Ordinal(rawValue: 5)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Sequence where Element == DateBuilder.Month {
    public func addingMonths(_ months: Int) -> [DateBuilder.Month] {
        return map({ $0.addingMonths(months) })
    }
    
    public var firstDay: [DateBuilder.Day] {
        return map({ $0.firstDay })
    }
    
    public var lastDay: [DateBuilder.Day] {
        return map({ $0.lastDay })
    }
    
    public func weekday(_ ordinal: DateBuilder.Ordinal, _ weekday: DateBuilder.Week.GregorianWeekday) -> [DateBuilder.Day] {
        return compactMap({ $0.weekday(ordinal, weekday) })
    }
    
    public func first(_ weekday: DateBuilder.Week.GregorianWeekday) -> [DateBuilder.Day] {
        return map({ $0.first(weekday) })
    }
}

public func ExactMonth(year: Int, month: Int) -> DateBuilder.Month {
    return .init(base: (year: year, month: month), offset: 0)
}

public func ThisMonth() -> DateBuilder.Month {
    return .thisMonth
}

public func NextMonth() -> DateBuilder.Month {
    return .nextMonth
}

public func MonthOf(_ date: Date) -> DateBuilder.Month {
    return .monthOf(date)
}

public func MonthOf(_ day: DateBuilder.Day) -> DateBuilder.Month {
    return .monthOf(day.finalize())
}

public func AddingMonths(_ months: Int, to month: DateBuilder.Month) -> DateBuilder.Month {
    return month.addingMonths(months)
}

public func EveryMonth(forMonths nextMonths: Int, starting startMonth: DateBuilder.Month, distribution: DelayDistribution = .normal) -> [DateBuilder.Month] {
    return distribution.generate(count: nextMonths, start: startMonth, addDelay: { $0.addingMonths($1) })
}

extension DateBuilder {
    public struct Year {
        var baseYear: Int
        var offset: Int
        
        public static var thisYear: Year {
            return yearOf(Date())
        }
        
        public static var nextYear: Year {
            return thisYear.addingYears(1)
        }
        
        public static func yearOf(_ date: Date) -> Year {
            let y = Year(baseYear: date._extract(.year), offset: 0)
            return y
        }
        
        private var baseDateComponents: DateComponents {
            return DateComponents(year: baseYear)
        }
        
        fileprivate func finalize() -> Date {
            let base = DateBuilder.calendar.date(from: baseDateComponents) ?? .distantFuture
            return DateBuilder.calendar.date(byAdding: .year, value: offset, to: base) ?? .distantFuture
        }
        
        public func addingYears(_ years: Int) -> Year {
            return Year(baseYear: baseYear, offset: offset + years)
        }
        
        public var firstMonth: Month {
            let month = Month.monthOf(finalize())
            return month
        }
        
        public var lastMonth: Month {
            guard var interval = DateBuilder.calendar.dateInterval(of: .year, for: finalize()) else {
                return firstMonth
            }
            // otherwise the end of the interval will be midnight of the first day of next month
            interval.end.addTimeInterval(-5)
            return Month.monthOf(interval.end)
        }
        
        public var allMonths: [Month] {
            guard var interval = DateBuilder.calendar.dateInterval(of: .year, for: finalize()) else {
                return []
            }
            interval.start.addTimeInterval(5)
            interval.end.addTimeInterval(-5)
            var current = interval.start
            var all: [Month] = []
            while interval.contains(current) {
                all.append(Month.monthOf(current))
                current = DateBuilder.calendar.date(byAdding: .month, value: 1, to: current) ?? .distantFuture
            }
            return all
        }
    }
}

extension Sequence where Element == DateBuilder.Year {
    public func addingYears(_ years: Int) -> [DateBuilder.Year] {
        return map({ $0.addingYears(years) })
    }
    
    public var firstMonth: [DateBuilder.Month] {
        return map({ $0.firstMonth })
    }
    
    public var lastMonth: [DateBuilder.Month] {
        return map({ $0.lastMonth })
    }
}

public func ExactYear(year: Int) -> DateBuilder.Year {
    return .init(baseYear: year, offset: 0)
}

public func ThisYear() -> DateBuilder.Year {
    return .thisYear
}

public func NextYear() -> DateBuilder.Year {
    return .nextYear
}

public func YearOf(_ date: Date) -> DateBuilder.Year {
    return .yearOf(date)
}

public func YearOf(_ day: DateBuilder.Day) -> DateBuilder.Year {
    return .yearOf(day.finalize())
}

public func YearOf(_ month: DateBuilder.Month) -> DateBuilder.Year {
    return YearOf(month.firstDay)
}

public func AddingYears(_ years: Int, to year: DateBuilder.Year) -> DateBuilder.Year {
    return year.addingYears(years)
}

public func EveryYear(forYears nextYears: Int, starting startYear: DateBuilder.Year, distribution: DelayDistribution = .normal) -> [DateBuilder.Year] {
    return distribution.generate(count: nextYears, start: startYear, addDelay: { $0.addingYears($1) })
}

public func ExactlyAt(_ date: Date) -> DateBuilder.ResolvedDate {
    return .exact(date)
}

fileprivate extension Date {
    func _extract(_ component: Calendar.Component, calendar: Calendar = DateBuilder.calendar) -> Int {
        return calendar.component(component, from: self)
    }
    
    func _extract(components: Set<Calendar.Component>, calendar: Calendar = DateBuilder.calendar) -> DateComponents {
        return calendar.dateComponents(components, from: self)
    }
}
