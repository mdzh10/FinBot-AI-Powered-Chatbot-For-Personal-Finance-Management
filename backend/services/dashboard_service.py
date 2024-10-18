from sqlalchemy.orm import Session
from models.transaction import Transaction, TransactionType
from models.account import Account
from sqlalchemy import func
from datetime import datetime


async def calculate_total_balance(db: Session, user_id: int):
    # Sum the current balance for all accounts of the user
    total_balance = db.query(func.sum(Account.balance)).filter(Account.user_id == user_id).scalar()
    return total_balance if total_balance else 0.0


async def get_debits_credits_in_date_range(db: Session, user_id: int, start_date: datetime, end_date: datetime):
    # Calculate total debits and credits in the date range
    debits = db.query(func.sum(Transaction.amount)).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == TransactionType.debit,
        Transaction.transaction_date.between(start_date, end_date)
    ).scalar()


    credits = db.query(func.sum(Transaction.amount)).filter(
        Transaction.user_id == user_id,
        Transaction.transaction_type == TransactionType.credit,
        Transaction.transaction_date.between(start_date, end_date)
    ).scalar()


    return debits if debits else 0.0, credits if credits else 0.0
