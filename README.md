# DateBuilder

<img src="_Media/icon.png" width="70">

**DateBuilder** allows you to create `Date` and `DateComponents` instances with ease in a visual and declarative manner. With **DateBuilder**, it's very trivial to define dates from as simple as *"tomorrow at 9pm"* or as complex as *"first fridays for the next 24 months, at random times between 3pm and 7pm"*.

Maintainer: [@dreymonde](https://github.com/dreymonde)

As of now, **DateBuilder** is in beta. Some APIs might be changed between releases.

**DateBuilder** is a stand-alone part of **[NiceNotifications](https://github.com/dreymonde/NiceNotifications)**, a Nice Photon framework that radically simplifies local notifications, from content to permissions.

## Usage

```swift
import DateBuilder

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
```

## Guide

### Anatomy of a date builder

Every **DateBuilder** expression ends on a specific _day_ (or a set of days if you use functions like `EveryDay`/`EveryMonth`/etc.). First you specify your expression down to a day, and then define the time of day by calling `at(hour:minute:)` function. For example:

```swift
NextWeek()
    .firstDay
    .at(hour: 10, minute: 15)
```

Once you have your `at` expression, your date is now fully resolved. You can get a ready-to-use `Date` or `DateComponents` instance by calling `.date()` or `.dateComponents()`.

Slightly more complicated example would be:

```swift
let dateComponents = NextYear()
    .firstMonth.addingMonths(3)
    .first(.thursday)
    .at(hour: 21, minute: 00)
    .dateComponents()
```

So we start on the scale of years, then we notch it down to the scale of months, and then we finally get the specific day, which in this case will be the first thursday of a 4th month of the next year. After that, we finalize our query by using the `at` function.

### Available functions

#### Day

```swift
// top-level
Today()
Tomorrow()
DayOf(account.createdAt)
ExactDay(year: 2021, month: 1, day: 26)
AddingDays(15, to: .today)
AddingDays(15, to: .dayOf(account.createdAt))
EveryDay(forDays: 100, starting: .tomorrow)
EveryDay(forDays: 100, starting: .dayOf(account.createdAt))

// instance
Today()
--->.addingDays(10)
```

#### Week

**NOTE:** the start and end of the week is determined by the currently set `Calendar` and its `Locale`. To learn how to customize the calendar object used for **DateBuilder** queries, see *"Customizing the Calendar / Locale / Timezone"* section below

```swift
// top-level
ThisWeek()
NextWeek()
WeekOf(account.createdAt)
WeekOf(Today()) // use any `DateBuilder.Day` instance here
AddingWeeks(5, to: .thisWeek)
EveryWeek(forWeeks: 10, starting: .nextWeek)

// instance
ThisWeek()
--->.addingWeeks(10) // Week
--->.firstDay // Day
--->.lastDay // Day
--->.allDays // [Day]
--->.weekday(.thursday) // Day
--->.weekendStartDay // Day
--->.weekendEndDay // Day
```

#### Month

```swift
// top-level
ThisMonth()
NextMonth()
MonthOf(account.createdAt)
MonthOf(Today()) // use any `DateBuilder.Day` instance here
ExactMonth(year: 2021, month: 03)
AddingMonths(3, to: .thisMonth)
EveryMonth(forMonths: 5, starting: .monthOf(account.createdAt))

// instance
ThisMonth()
--->.addingMonths(5) // Month
--->.firstDay // Day
--->.lastDay // Day
--->.allDays // [Day]
--->.first(.saturday) // Day
--->.weekday(.third, .friday) // Day
```

#### Year

```swift
// top-level
ThisYear()
NextYear()
YearOf(account.createdAt)
YearOf(Tomorrow()) // use any `DateBuilder.Day` instance here
YearOf(NextMonth()) // use any `DateBuilder.Month` instance here
ExactYear(year: 2022)
AddingYears(1, to: ThisYear())
EveryYear(forYears: 100, starting: .thisYear)

// instance
ThisYear()
--->.addingYears(1) // Year
--->.firstMonth // Month
--->.lastMonth // Month
--->.allMonths // [Month]
```

#### Resolving the date

```swift
Today()
--->.at(hour: 10, minute: 15)
--->.at(hour: 19, minute: 30, second: 30)
--->.at(TimeOfDay(hour: 10, minute: 30, second: 0)) // equivalent to:
--->.at(.time(hour: 10, minute: 30))
--->.at(.randomTime(from: .time(hour: 10, minute: 15), to: .time(hour: 15, minute: 30)))
```

```swift
Today()
    .at(hour: 9, minute: 15)
    .date() // Date
    
// or

Today()
    .at(hour: 9, minute: 15)
    .dateComponents() // DateComponents
```

You can also get the `DateComponents` (but not `Date`) instance by calling `dateComponents()` on an instance of `DateBuilder.Day`, without using `at`:

```swift
NextMonth()
    .firstDay
    .dateComponents() // year: 2021, month: 2, day: 1
```

#### Using `ExactlyAt` function

`ExactlyAt` creates a resolved date from the existing `Date` instance. You can then use it to perform easy date calculations (functions `addingMinutes`/`addingHours` etc.) and easily get `Date` or `DateComponents` instances.

```swift
ExactlyAt(account.createdAt)
--->.addingSeconds(30)
--->.addingMinutes(1)
--->.addingHours(5)
--->.addingDays(20)
--->.addingMonths(3)
--->.addingWeeks(14)
--->.addingYears(1)

// usge:
ExactlyAt(account.createdAt)
    .addingMinutes(15)
    .dateComponents() // DateComponents
```

### Using `Every` functions

You can use `EveryDay`, `EveryWeek`, `EveryMonth` and `EveryYear` functions in the same way as you would use something like `Today()` or `NextYear()`. The only difference is that at the end you will get an array of dates instead of a single instance:

```swift
let dates = EveryMonth(forMonths: 12, starting: .thisMonth)
    .firstDay.addingDays(9)
    .at(hour: 20, minute: 00)
    .dates() // [Date]
    
// or

let dates = EveryMonth(forMonths: 12, starting: .thisMonth)
    .lastDay.addingDays(-5)
    .at(hour: 20, minute: 00)
    .dateComponents() // [DateComponents]
```

In case you use `.at(.randomTime( ... ))` function with `Every` functions, the exact resolved time will be different each day.

### Customizing the Calendar / Locale / Timezone

By default, **DateBuilder** uses `Calendar.current` for all calculations. If you need to customize it, you can either change it globally:

```swift
var customCalendar = DateBuilder.calendar
customCalendar.firstWeekday = 6
DateBuilder.calendar = customCalendar
```

Or temporarily, using the `DateBuilder.withCalendar` function:

```swift
DateBuilder.withCalendar(customCalendar) {
    ThisWeek().firstDay.dateComponents()
}
```

**DateBuilder** will return to its global `Calendar` instance after evaluating the expression.

In a similar manner, you can also use `DateBuilder.withTimeZone` and `DateBuilder.withLocale` functions:

```swift
DateBuilder.withTimeZone(TimeZone(identifier: "America/Cancun")) {
    Tomorrow().at(hour: 9, minute: 15).date()
}

let nextFriday = DateBuilder.withLocale(Locale(identifier: "he_IL")) {
    NextWeek()
        .weekendStartDay
        .at(hour: 7, minute: 00)
        .date() // next friday!
}
```

All of these functions support returning the result of the closure (see above).

## Installation

### Swift Package Manager
1. Click File &rarr; Swift Packages &rarr; Add Package Dependency.
2. Enter `http://github.com/nicephoton/DateBuilder.git`.

## Acknowledgments

Special thanks to:

 - [@mattt](https://github.com/mattt) for his wonderful article: [Date​Components - NSHipster](https://nshipster.com/datecomponents/)
 - [@camanjj](https://github.com/camanjj) for his valuable feedback on the API

Related materials:

 - **[Time](https://github.com/dreymonde/Time)** by [@dreymonde](https://github.com/dreymonde) - Type-safe time calculations in Swift, powered by generics
 - **[Time](https://github.com/davedelong/Time)** by [@davedelong](https://github.com/dreymonde) - Building a better date/time library for Swift
