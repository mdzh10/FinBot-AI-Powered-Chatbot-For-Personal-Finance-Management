from sqlalchemy.orm import Session
from models.transaction import Transaction, TransactionType
from schemas.transaction_schema import TransactionResponse,TransactionCreate
from typing import List

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
