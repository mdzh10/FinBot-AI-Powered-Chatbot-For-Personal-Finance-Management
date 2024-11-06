from sqlalchemy.orm import Session
from models.transaction import Transaction, TransactionType
from schemas.transaction_schema import TransactionResponse, TransactionCreate
from typing import List
from fastapi import HTTPException

async def get_all_transactions(db: Session, user_id: int) -> List[TransactionResponse]:
    # Fetch all transactions for the given user
    transactions = db.query(Transaction).filter(Transaction.user_id == user_id).all()

    if not transactions:
        return None

    # Prepare the transaction responses
    transaction_list = []
    for transaction in transactions:
        transaction_list.append(TransactionResponse(
            id=transaction.id,
            user_id=transaction.user_id,
            account_id=transaction.account_id,
            category_id=transaction.category_id,
            item_name=transaction.item_name,
            quantity=transaction.quantity,
            amount=transaction.amount,
            transaction_type="debit" if transaction.transaction_type == TransactionType.debit else "credit",
            transaction_date=transaction.transaction_date
        ))

    return transaction_list

async def add_transaction(db: Session, transaction: TransactionCreate):

    new_transaction=Transaction( 

         user_id= transaction.user_id,
         account_id=transaction.account_id,
         category_id=transaction.category_id,
         item_name=transaction.item_name,
         quantity=transaction.quantity,
         amount=transaction.amount,
         transaction_type=transaction.transaction_type,
         transaction_date=transaction.transaction_date

    )
    db.add(new_transaction)
    db.commit()
    db.refresh(new_transaction)
    return new_transaction

async def update_transaction(db: Session,transaction_id: int, transaction: TransactionCreate):
    existing_transaction=db.query(Transaction).filter(Transaction.id==transaction_id).first()
    if not existing_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    existing_transaction.item_name = transaction.item_name
    existing_transaction.quantity = transaction.quantity
    existing_transaction.amount = transaction.amount
    existing_transaction.transaction_type = transaction.transaction_type
    db.commit()
    db.refresh(existing_transaction)
    return existing_transaction

def delete_transaction_by_id(db: Session, transaction_id: int):
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if transaction is None:
        print(f"No transaction found with ID: {transaction_id}")
        return None
    print(f"Deleting transaction with ID: {transaction_id}")
    db.delete(transaction)
    db.commit()
    return transaction