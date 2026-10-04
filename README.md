# No Entry – Smart Door Security App

A smart door security application that provides real-time monitoring and alerts when unauthorized access or door tampering is detected.

## 📌 Overview

No Entry is a Flutter-based smart door security application integrated with ESP32 hardware and Supabase. The system monitors connected door sensors and immediately alerts the registered user when suspicious or unauthorized door activity is detected.

The application provides secure authentication, real-time door monitoring, device management, and instant security notifications through a clean and interactive mobile interface.

## ✨ Features

- 🔐 Secure user authentication
- 📡 Real-time door sensor monitoring
- 🚪 Smart door tamper detection
- 🔔 Instant security notifications
- 📱 Full-screen call-like security alerts
- 📳 Vibration and sound alerts
- 📶 Wi-Fi device discovery
- 🔗 Multiple smart-door device support
- 👤 User profile management
- ⚙️ Device management
- 🌙 Dark mode support
- ☁️ Supabase real-time database integration
- 🔒 Secure backend authentication and data management

## 🏗️ System Architecture

```text
              ┌─────────────────────┐
              │   Smart Door Sensor │
              │       ESP32         │
              └──────────┬──────────┘
                         │
                         │ Wi-Fi
                         ↓
              ┌─────────────────────┐
              │   Supabase Backend  │
              │                     │
              │ Authentication      │
              │ Realtime Database   │
              │ Device Management   │
              │ Notifications       │
              └──────────┬──────────┘
                         │
                         │ Internet
                         ↓
              ┌─────────────────────┐
              │   Flutter Mobile    │
              │        App          │
              │                     │
              │ Dashboard           │
              │ Device Management   │
              │ Security Alerts     │
              │ Settings            │
              └─────────────────────┘
