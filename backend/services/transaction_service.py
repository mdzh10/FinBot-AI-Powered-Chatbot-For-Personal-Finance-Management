from sqlalchemy.orm import Session
from models.category import Category
from models.transaction import Transaction, PaymentTypeEnum
from models.account import Account
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
            user_id=user_id,
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
        transactions=transaction_list,
    )


async def add_transaction(
    db: Session, transaction: TransactionCreate
) -> TransactionListResponse:
    # Find the associated account for this transaction
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

    # Find the associated account
    account = db.query(Account).filter(Account.id == new_transaction.account_id).first()
    category = (
        db.query(Category).filter(Category.id == new_transaction.category_id).first()
    )
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    # Update the account balance based on transaction type
    if new_transaction.type == PaymentTypeEnum.credit:
        account.balance += new_transaction.amount
        account.credit += new_transaction.amount  # Track total credits
    elif new_transaction.type == PaymentTypeEnum.debit:
        if account.balance < new_transaction.amount:
            raise HTTPException(status_code=400, detail="Insufficient balance")
        account.balance -= new_transaction.amount
        account.debit += new_transaction.amount  # Track total debits
    category.expense += new_transaction.amount

    db.commit()
    db.refresh(new_transaction)
    db.refresh(account)
    db.refresh(category)

    return TransactionListResponse(
        msg="Transaction Created successfully",
        transactions=[
            TransactionDetails(
                id=new_transaction.id,
                user_id=new_transaction.user_id,
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
    # Fetch the existing transaction
    existing_transaction = (
        db.query(Transaction).filter(Transaction.id == transaction.id).first()
    )
    category = (
        db.query(Category)
        .filter(Category.id == existing_transaction.category_id)
        .first()
    )
    if not existing_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    # Fetch the associated account
    account = (
        db.query(Account).filter(Account.id == existing_transaction.account_id).first()
    )
    if not account:
        raise HTTPException(status_code=404, detail="Associated account not found")

    # Store original transaction amount and type
    original_amount = existing_transaction.amount
    original_type = existing_transaction.type

    # Adjust account balance based on the original transaction type
    if original_type == PaymentTypeEnum.credit:
        account.balance -= original_amount  # Remove original credit
        account.credit -= original_amount
    elif original_type == PaymentTypeEnum.debit:
        account.balance += original_amount  # Remove original debit
        account.debit -= original_amount
    category.expense -= original_amount

    # Now apply the updated transaction values
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
        existing_transaction.type = PaymentTypeEnum[transaction.type]
    if transaction.datetime is not None:
        existing_transaction.datetime = transaction.datetime

    # Adjust the account balance based on the updated transaction
    if existing_transaction.type == PaymentTypeEnum.credit:
        account.balance += existing_transaction.amount
        account.credit += existing_transaction.amount
    elif existing_transaction.type == PaymentTypeEnum.debit:
        if account.balance < existing_transaction.amount:
            raise HTTPException(
                status_code=400, detail="Insufficient balance, Update failed"
            )
        account.balance -= existing_transaction.amount
        account.debit += existing_transaction.amount
    category.expense += existing_transaction.amount

    # Commit changes to both the transaction and the account
    db.commit()
    db.refresh(existing_transaction)
    db.refresh(account)
    db.refresh(category)

    return TransactionListResponse(
        msg="Transaction Updated Successfully",
        transactions=[
            TransactionDetails(
                id=existing_transaction.id,
                user_id=existing_transaction.user_id,
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

    # Fetch the associated account
    account = db.query(Account).filter(Account.id == transaction.account_id).first()
    category = db.query(Category).filter(Category.id == transaction.category_id).first()
    # Store original transaction amount and type
    original_amount = transaction.amount
    original_type = transaction.type

    # Adjust account balance based on the original transaction type
    if original_type == PaymentTypeEnum.credit:
        account.balance -= original_amount  # Remove original credit
        account.credit -= original_amount
    elif original_type == PaymentTypeEnum.debit:
        account.balance += original_amount  # Remove original debit
        account.debit -= original_amount
    category.expense -= original_amount

    db.delete(transaction)
    db.commit()
    db.refresh(account)
    db.refresh(category)

    return True
