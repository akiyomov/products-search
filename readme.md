# BDS App

## Overview

This repository contains the backend Flask API and the Flutter mobile application for the BDS (Boycott, Divestment, and Sanctions) app. The backend API is built using Flask, providing functionality to retrieve product information, including boycott reasons for specific companies, based on a provided barcode. The Flutter app interfaces with this API to display product details and support user interactions.

## Components

### Backend (Flask)

- **Description:** The backend Flask API serves as the core of the BDS app, providing endpoints to fetch product information and boycott reasons.
- **Technologies:** Flask, Pandas, Requests
- **Endpoints:** `/get_product_info`

### Frontend (Flutter)

- **Description:** The Flutter mobile application serves as the frontend interface for the BDS app, allowing users to scan barcodes and view product details.
- **Technologies:** Flutter, Dart
- **Features:** Barcode scanning, Product details display, Language selection

## Setup Instructions

1. Clone this repository to your local machine.

2. Navigate to the `backend` directory and follow the README instructions to set up the Flask backend.

3. Navigate to the `flutter_app` directory and follow the README instructions to set up the Flutter mobile application.

4. Run the Flask backend server and deploy the Flutter app to a mobile device or emulator to start using the BDS app.

## Usage

- Use the Flutter app to scan product barcodes and view boycott reasons for specific companies.
- Use the Flask backend API to extend functionality or integrate with other services as needed.
