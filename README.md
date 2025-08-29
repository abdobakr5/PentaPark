# IoT-Based Project Documentation

## 1. Overview

This project integrates IoT devices, cloud services, and a mobile application to provide real-time monitoring, control, and data visualization. The system uses **ESP32**, **HiveMQ**, **Supabase**, and **Flutter** to deliver a seamless experience.

# Makket

![Makket](https://github.com/user-attachments/assets/3bd123ff-6133-4606-9446-f013a5beecef)

---

## 2. Hardware Schema

This section contains the hardware wiring and circuit design for the project.

- **Microcontroller**: ESP32.
- **Hardware componentes**: 4 IR Sensors, LCD, 2 Servo motors, LED, Buzzer, Temperature sensor, and filnally Gas Sensor.
- **Connections**: Full schematic diagram included.
- **Simulation**: [Wokwi-based simulation](https://wokwi.com/projects/440201159960637441).

- Schema
  ![Hardware Schema](https://github.com/user-attachments/assets/48e915dd-4a32-412e-ac91-902e8216948b)
- Photo 1
  ![Hardware Wiring 1](https://github.com/user-attachments/assets/2d66df3c-d0fc-4651-8309-4132b4d9a203)
- Photo 2

![Hardware Wiring 2](https://github.com/user-attachments/assets/79015acf-13bc-4936-9b36-c48ec4914797)

- Photo 3
  ![Hardware Wiring 3](https://github.com/user-attachments/assets/aab223c5-a55d-4383-a48d-373831b4b7b2)

---

## 3. Cloud (HiveMQ)

HiveMQ is used as the MQTT broker for real-time communication between the IoT devices and the mobile app and used for sending commands dirictly from the app to the ESP.

- **Broker**: HiveMQ
- **Protocol**: MQTT
- **Topic Structure**: Organized by device and data type.
- **QoS**: Ensures reliable delivery of messages.

---

## 4. Database & Backend (Supabase)

Supabase is used as the backend for managing users, storing device data, and providing authentication.

- **Database**: PostgreSQL (Managed by Supabase).
- **Authentication**: Supabase Auth.
- **API**: RESTful APIs for CRUD operations.
- **Realtime**: WebSocket support for live updates.
- Schema
  ![DB Schema](https://github.com/user-attachments/assets/61f49216-e2af-4156-a621-81b2028294c6)
- Users
  ![Users](https://github.com/user-attachments/assets/288f0e24-e704-4b7f-b196-4ed0340584c5)
  **Our users table to take data as we wants from user registraion form**
- _Users_
  ![photo_23_2025-08-29_01-16-18](https://github.com/user-attachments/assets/fed41422-f3a5-4e0b-9edc-e93ca8977a06)

---

## 5. UI/UX

The project's design focuses on a modern and intuitive user interface.

- **Design Tool**: Figma
- **User Flows**: Designed for a smooth user experience.

[UI Design](https://www.figma.com/design/Pby2EZ503pFrUEVLuXCTsf/first1?node-id=179-228&t=m18hTv9XX91JvKK1-1)

---

## 6. Mobile Application (Flutter)

The mobile app is built using **Flutter** and connected to Supabase & HiveMQ.

- **Framework**: Flutter (Clean Architecture).
- **Authentication**: Integrated with Supabase.
- **Real-time Updates and commands from ControlPage**: Via HiveMQ MQTT channels.
- **Platforms**: Android Supported.
- **App workflow**:
  1. Sign up or Sign in.
  2. HomePage
  3. Dashboard that show all live sensors data and doors status.
  4. Control Page that make you can control Doors and LED and Buzzer.
  5. Alert system the give you alert when a car wants to enter or leave your garage and when gas leekage or overheat.

<p align="center">
  <img src="https://github.com/user-attachments/assets/bba8237b-7792-427e-8f63-79f814a40bc5" width="250" />
  <img src="https://github.com/user-attachments/assets/0ad13ecd-13e1-409c-801d-bc1834855ebc" width="250" />
  <img src="https://github.com/user-attachments/assets/21e393e2-5cd6-46a4-b2db-7e51cb7fadd3" width="250" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/4f32594c-9be5-4a82-82b9-68ca431901e6" width ="250"/>
  <img src="https://github.com/user-attachments/assets/184b3c7c-ba76-448d-b35f-f94d5e6bb452" width="250" />
  <img src="https://github.com/user-attachments/assets/4a27f0da-8bd8-40e9-bb88-81c701dfb2e9" width="250" />
  <img src="https://github.com/user-attachments/assets/f7079818-4f67-48cc-8f6b-1adb44c6e8b8" width="250" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/083d933b-4f1d-46bc-9548-e22d03ccbdc5" width="250" />
  <img src="https://github.com/user-attachments/assets/2ff46e4d-cc35-4d01-aef6-80f9811cd759" width="250" />
  <img src="https://github.com/user-attachments/assets/b61d1b4c-fd29-413e-af46-d5374d8f5267" width="250" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/3e0ab98a-8f79-4f7e-bbe2-e5a68f285829" width="250" />
  <img src="https://github.com/user-attachments/assets/49e8b9e1-97f0-48fd-abc8-2f6e7887282a" width="250" />
  <img src="https://github.com/user-attachments/assets/b66d9071-6b6e-4733-b432-049b566bb476" width="250" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/ffe1ec42-0380-4c92-a06a-9c3dfc823045" width="250" />
  <img src="https://github.com/user-attachments/assets/d1cce46e-8a38-4d46-82a5-846fac9e2f68" width="250" />
</p>

---

### Developed by:

| Member Name       | Role                              |
| ----------------- | --------------------------------- |
| Shrouk Yasser     | Hardware & Wiring                 |
| Karram Yasser     | Cloud Integration (HiveMQ)        |
| Ahmed Hossam      | Database & Backend                |
| Alzahraa Ibrahim  | UI/UX Design                      |
| Abdelrhman Khaled | Flutter Development (Team Leader) |

Faculty of Computer & Data Science, Alexandria University.
