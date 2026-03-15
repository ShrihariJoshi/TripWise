# 🌍 TripWise

TripWise is an **end-to-end trip management mobile application** designed to simplify group travel.
It provides tools for **trip planning, itinerary management, and intelligent expense splitting**, allowing travelers to organize trips and settle shared expenses efficiently.

The platform combines a **Flutter mobile frontend**, a **Flask backend API**, and a **Supabase-hosted PostgreSQL database** to deliver a scalable and structured travel management system.

---

# ✨ Key Features

### 🧳 Trip Management

* Create and manage trips
* Invite and manage trip members
* Centralized trip dashboard

### 📅 Itinerary Planning

* Add day-wise trip activities
* Organize travel schedules
* Track planned locations and events

### 💰 Smart Expense Splitting

* Record shared expenses
* Automatically calculate settlements
* Reduce number of payments between group members

### 👥 Group Collaboration

* Multiple participants per trip
* Shared expense tracking
* Transparent balance overview

---

# 🧠 SmartSplit Algorithm

TripWise includes a **SmartSplit expense settlement algorithm** built using a **greedy approach**.

Goal:
Minimize the number of transactions required to settle group expenses.

Process:

1. Calculate each participant's **net balance**.
2. Identify **debtors** and **creditors**.
3. Greedily match the largest debtor with the largest creditor.
4. Continue settlement until balances reach zero.

Benefits:

* Reduces payment complexity
* Minimizes number of transfers
* Efficient for group expense resolution

---

# 🏗 System Architecture

TripWise follows a **mobile client → API → database architecture**.

```
Flutter Mobile App
        │
        ▼
Flask REST API
        │
        ▼
Supabase PostgreSQL Database
```

### Components

**Mobile Client**

* Built with Flutter
* Handles UI, trip interactions, and expense inputs

**Backend API**

* Built using Flask
* Handles business logic and CRUD operations
* Implements SmartSplit expense logic

**Database**

* PostgreSQL hosted on Supabase
* Stores trips, members, itineraries, and expenses

---

# 🛠 Tech Stack

### Mobile

* Flutter
* Dart

### Backend

* Flask (Python)

### Database

* PostgreSQL (Supabase)

### Architecture

* REST API
* CRUD-based service design



# ⚙️ Running the Project

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/ShrihariJoshi/TripWise.git
cd TripWise
```

### 2️⃣ Start Backend

```bash
cd backend
pip install -r requirements.txt
python app.py
```

### 3️⃣ Run Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

---

# 📊 Core Engineering Concepts Demonstrated

This project demonstrates:

* Full-stack mobile application development
* REST API design using Flask
* PostgreSQL database integration
* Algorithmic optimization
* CRUD service architecture
* Multi-user data handling



# 👨‍💻 Author

TripWise was built as a full-stack system demonstrating mobile development, backend architecture, and algorithmic problem solving.

---

# 📄 License

MIT License
