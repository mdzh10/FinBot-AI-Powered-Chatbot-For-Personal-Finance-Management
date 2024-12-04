# FinBot: AI-Powered Chatbot for Personal Finance Management

## Our Vision

**FOR** people facing challenges in managing their finances  
**WHO** want to track their personal daily transactional activities, categorize spending, and gain insights into their purchases,  
**THE** FinBot: AI-Driven Personal Finance Manager is a mobile application  
**THAT** tracks daily transactions, sets financial goals, and categorizes spending based on receipt images using AI.  
**UNLIKE** other apps like Wallet, Mint, and YNAB, which handle daily finances manually,  
**OUR PRODUCT** provides AI assistance that allows users to generate customized financial reports and answer financial history questions through a chatbot.

---

## Features

- **AI-Powered Receipt Scanning**: Automatically categorizes spending by analyzing receipt images.
- **Transaction Tracking**: Keep a log of daily transactions, including incomes and expenses.
- **Goal Setting**: Define financial goals and monitor your progress.
- **Interactive Chatbot**: Get instant answers to financial history questions using an AI chatbot.
- **Custom Reports**: Generate tailored financial reports to understand spending habits and trends.

---

## Installation

### Backend Setup

1. **Run the Backend Locally**:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --log-level info

2. **Build the Docker Image**:
   ```bash
   docker build -t fastapi-backend .

3. **Run the Docker Container Locally for Testing**:
   ```bash
   docker run -d -p 8000:8000 fastapi-backend

## Contact

If you have any questions or need support, feel free to:

- Open an issue in this repository [here](https://github.com/mdzh10/FinBot-AI-Powered-Chatbot-For-Personal-Finance-Management/issues).
<!-- - Contact the project maintainers directly via email: [ mdzh1997@gmail.com, rifatfahmida00@gmail.com] -->