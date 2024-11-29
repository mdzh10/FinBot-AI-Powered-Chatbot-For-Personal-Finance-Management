from datetime import datetime
from typing import List, Optional
from fastapi.params import Query
from sqlalchemy.orm import Session
from schemas.account_schema import AccountDetails
from schemas.category_schema import CategoryDetails
from models.category import Category
from models.transaction import Transaction, PaymentTypeEnum
from models.account import Account
from schemas.transaction_schema import (
    TransactionListResponse,
    TransactionCreate,
    TransactionDetails,
    TransactionUpdate,
)
from fastapi import HTTPException


async def get_all_transactions(
    db: Session,
    user_id: int,
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
) -> TransactionListResponse:
    # Start with base query
    transaction_query = db.query(Transaction).filter(Transaction.user_id == user_id)

    # Apply date range filter if provided
    if start_date:
        transaction_query = transaction_query.filter(Transaction.datetime >= start_date)

    if end_date:
        transaction_query = transaction_query.filter(Transaction.datetime <= end_date)

    # Execute query
    transactions = transaction_query.all()
    accounts = db.query(Account).filter(Account.user_id == user_id).all()
    categories = db.query(Category).filter(Category.user_id == user_id).all()

    if not transactions:
        raise HTTPException(
            status_code=404, detail="No transactions found for this user"
        )

    # Create dictionaries for quick lookup of accounts and categories by their IDs
    account_dict = {
        account.id: AccountDetails.from_orm(account) for account in accounts
    }
    category_dict = {
        category.id: CategoryDetails.from_orm(category) for category in categories
    }

    # Build the transaction list with full account and category details
    transaction_list = [
        TransactionDetails(
            id=transaction.id,
            user_id=user_id,
            account=account_dict.get(transaction.account_id),
            category=category_dict.get(transaction.category_id),
            title=transaction.title,
            description=transaction.description,
            isExceed=transaction.isExceed,
            amount=transaction.amount,
            type=transaction.type,
            datetime=transaction.datetime,
        )
        for transaction in transactions
    ]

    return TransactionListResponse(
        isSuccess=True,
        msg="Transactions fetched successfully",
        transactions=transaction_list,
    )


async def add_transactions(
    db: Session, transactions: List[TransactionCreate]
) -> TransactionListResponse:
    transaction_details_list = []

    # Assume all transactions belong to the same account (based on first transaction's account_id)
    if not transactions:
        raise HTTPException(status_code=400, detail="No transactions provided")

    # Fetch the associated account once
    account_id = transactions[0].account_id
    account = db.query(Account).filter(Account.id == account_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    
    # Check if today is the start of the month and reset category expenses if needed
    today = datetime.now().date()
    if today.day == 1:
        db.query(Category).update({Category.expense: 0.0})
        db.commit()
        
    # Fetch categories once for all category_ids in the transactions
    category_ids = {
        transaction.category_id
        for transaction in transactions
        if transaction.category_id
    }
    categories = {
        category.id: category
        for category in db.query(Category).filter(Category.id.in_(category_ids)).all()
    }

    for transaction in transactions:
        # Ensure the category exists if provided
        category = categories.get(transaction.category_id)
        if transaction.category_id and not category:
            raise HTTPException(
                status_code=404,
                detail=f"Category ID {transaction.category_id} not found",
            )

        # Create a new transaction record
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

        # Update the account balance based on transaction type
        if new_transaction.type == PaymentTypeEnum.credit:
            account.balance += new_transaction.amount
            account.credit += new_transaction.amount  # Track total credits
            if category:
                category.expense -= new_transaction.amount
        elif new_transaction.type == PaymentTypeEnum.debit:
            if account.balance < new_transaction.amount:
                raise HTTPException(status_code=400, detail="Insufficient balance")
            account.balance -= new_transaction.amount
            account.debit += new_transaction.amount  # Track total debits
            if category:
                category.expense += new_transaction.amount

        # Check if category expense exceeds budget
        is_exceed = True if category and category.expense > category.budget else False

        db.commit()
        db.refresh(new_transaction)

        # Convert to Pydantic models
        account_details = AccountDetails.from_orm(account)
        category_details = CategoryDetails.from_orm(category) if category else None
        transaction_details = TransactionDetails(
            id=new_transaction.id,
            user_id=new_transaction.user_id,
            account=account_details,
            category=category_details,
            title=new_transaction.title,
            description=new_transaction.description,
            isExceed=is_exceed,  # Set isExceed flag
            amount=new_transaction.amount,
            type=new_transaction.type,
            datetime=new_transaction.datetime,
        )
        transaction_details_list.append(transaction_details)

    # Refresh account and category after all transactions are processed
    db.refresh(account)
    for category in categories.values():
        db.refresh(category)

    return TransactionListResponse(
        msg="Transactions created successfully", transactions=transaction_details_list
    )


async def update_transaction(
    db: Session, transaction: TransactionUpdate
) -> TransactionListResponse:
    # Fetch the existing transaction
    existing_transaction = (
        db.query(Transaction).filter(Transaction.id == transaction.id).first()
    )

    if not existing_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    # Fetch the associated account and original category
    account = (
        db.query(Account).filter(Account.id == existing_transaction.account_id).first()
    )
    original_category = (
        db.query(Category)
        .filter(Category.id == existing_transaction.category_id)
        .first()
    )

    if not account:
        raise HTTPException(status_code=404, detail="Associated account not found")
    if not original_category:
        raise HTTPException(status_code=404, detail="Original category not found")

    # Store original transaction amount and type
    original_amount = existing_transaction.amount
    original_type = existing_transaction.type

    # Adjust account balance and original category expense based on original transaction type
    if original_type == PaymentTypeEnum.credit:
        account.balance -= original_amount
        account.credit -= original_amount
    elif original_type == PaymentTypeEnum.debit:
        account.balance += original_amount
        account.debit -= original_amount
    original_category.expense -= original_amount

    # Update the transaction fields
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

    # Fetch the new category (if it has changed)
    new_category = (
        db.query(Category)
        .filter(Category.id == existing_transaction.category_id)
        .first()
    )
    if not new_category:
        raise HTTPException(status_code=404, detail="New category not found")

    # Adjust account balance and new category expense based on the updated transaction type
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

    # Adjust expenses for the new category
    new_category.expense += existing_transaction.amount

    # Commit changes and refresh instances
    db.commit()
    db.refresh(existing_transaction)
    db.refresh(account)
    db.refresh(original_category)
    db.refresh(new_category)

    # Convert ORM instances to Pydantic models for response
    account_details = AccountDetails.from_orm(account)
    category_details = CategoryDetails.from_orm(new_category)
    transaction_details = TransactionDetails(
        id=existing_transaction.id,
        user_id=existing_transaction.user_id,
        account=account_details,
        category=category_details,
        title=existing_transaction.title,
        description=existing_transaction.description,
        amount=existing_transaction.amount,
        type=existing_transaction.type,
        datetime=existing_transaction.datetime,
    )

    return TransactionListResponse(
        msg="Transaction updated successfully", transactions=[transaction_details]
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
