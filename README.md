# MoiPari – Personal Budget & Expense Tracker
<img width="617" height="404" alt="MoiPari-removebg-preview" src="https://github.com/user-attachments/assets/664f59bf-dd43-4841-b394-24ce075bae52" />

Cross-platform personal finance app built with Flutter (mobile UI) and Kotlin Spring Boot (backend).
The app helps users track expenses, manage budgets, and view spending insights with clean visuals and real-time updates.

This project is a work in progress, with new features and improvements being added continuously.

## Technologies Used

Frontend
- Flutter (Dart)
- Provider / Riverpod (state management)
- Responsive, cross-platform UI

Backend
- Kotlin + Spring Boot
- PostgreSQL (for data persistence)
- JPA/Hibernate
- REST API architecture

## Exchange Rate API (Backend Explanation)

How It Works
- The Kotlin backend calls a real external exchange-rate provider (such as OpenExchangeRates, ExchangeRate API, or a European Central Bank API).
- The backend receives the latest MKD/EUR/USD conversion rates.
- The Flutter app requests conversion only through:
  
 ```
 GET /api/exchange?from=MKD&to=EUR
```
 
- The backend responds with:
 ```
  {
  "rate": 0.01625
  }
```

## Installation
Backend (Kotlin)
```
./gradlew bootRun
```

Frontend (Flutter)
```
flutter pub get
flutter run
```

