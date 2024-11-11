from sqlalchemy.orm import Session
from models.transaction import Transaction, PaymentTypeEnum
from schemas.transaction_schema import (
    TransactionListResponse,
    TransactionCreate,
    TransactionDetails,
)
from fastapi import HTTPException


async def get_all_transactions(db: Session, user_id: int) -> TransactionListResponse:
    transactions = db.query(Transaction).filter(Transaction.user_id == user_id).all()

    if not transactions:
        raise HTTPException(
            status_code=404, detail="No transactions found for this user"
        )

    transaction_list = [
        TransactionDetails(
            id=transaction.id,
            account_id=transaction.account_id,
            category_id=transaction.category_id,
            title=transaction.title,
            description=transaction.description,
            amount=transaction.amount,
            type="debit" if transaction.type == PaymentTypeEnum.debit else "credit",
            datetime=transaction.datetime,
        )
        for transaction in transactions
    ]

    return TransactionListResponse(
        isSuccess=True,
        msg="Transactions fetched successfully",
        user_id=user_id,
        transactions=transaction_list,
    )


async def add_transaction(
    db: Session, transaction: TransactionCreate
) -> TransactionListResponse:
    new_transaction = Transaction(
        user_id=transaction.user_id,
        account_id=transaction.account_id,
        category_id=transaction.category_id,
        title=transaction.title,
        description=transaction.description,
        amount=transaction.amount,
        type=(
            PaymentTypeEnum.debit
            if transaction.type == "debit"
            else PaymentTypeEnum.credit
        ),
        datetime=transaction.datetime,
    )
    db.add(new_transaction)
    db.commit()
    db.refresh(new_transaction)

    return TransactionListResponse(
        msg="Transaction Created successfully",
        user_id=new_transaction.user_id,
        transactions=[
            TransactionDetails(
                id=new_transaction.id,
                account_id=new_transaction.account_id,
                category_id=new_transaction.category_id,
                title=new_transaction.title,
                description=new_transaction.description,
                amount=new_transaction.amount,
                type=new_transaction.type,
                datetime=new_transaction.datetime,
            )
        ],
    )


async def update_transaction(
    db: Session, transaction: TransactionDetails
) -> TransactionListResponse:
    existing_transaction = (
        db.query(Transaction).filter(Transaction.id == transaction.id).first()
    )

    if not existing_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

# Update only the fields provided in transaction_data
    if transaction.account_id is not None:
        existing_transaction.account_id = transaction.account_id
    if transaction.category_id is not None:
        existing_transaction.category_id = transaction.category_id
    if transaction.title is not None:
        existing_transaction.title = transaction.title
    if transaction.description is not None:
        existing_transaction.description = transaction.description
    if transaction.amount is not None:
        existing_transaction.amount = transaction.amount
    if transaction.type is not None:
        existing_transaction.type = transaction.type
    if transaction.datetime is not None:
        existing_transaction.datetime = transaction.datetime

    db.commit()
    db.refresh(existing_transaction)

    return TransactionListResponse(
        msg="Transaction Updated Successfully",
        user_id=existing_transaction.user_id,
        transactions=[
            TransactionDetails(
                id=existing_transaction.id,
                account_id=existing_transaction.account_id,
                category_id=existing_transaction.category_id,
                title=existing_transaction.title,
                description=existing_transaction.description,
                amount=existing_transaction.amount,
                type=existing_transaction.type,
                datetime=existing_transaction.datetime,
            )
        ],
    )


async def delete_transaction_by_id(db: Session, transaction_id: int) -> bool:
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id).first()
    if not transaction:
        return False

    db.delete(transaction)
    db.commit()
    return True
