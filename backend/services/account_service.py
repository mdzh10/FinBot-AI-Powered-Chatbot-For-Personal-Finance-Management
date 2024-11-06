from sqlalchemy.orm import Session
from models.account import Account
from schemas.account_schema import AccountCreate, AccountResponse, AccountDetails
from typing import List
from fastapi import HTTPException


async def get_all_accounts(db: Session, user_id: int) -> AccountResponse:
    # Fetch all accounts for the given user
    accounts = db.query(Account).filter(Account.user_id == user_id).all()

    if not accounts:
        return AccountResponse(
            isSuccess=False, msg="No accounts found", accounts=[]
        ).dict()  # Ensure dict conversion

    # Prepare the account list based on the specified structure
    account_list = [
        AccountDetails(
            id=account.id,
            name=account.account_name,
            holderName=account.account_name,
            accountNumber=account.account_number,
            balance=account.balance,
            credit=account.credit,
            debit=account.debit,
        )
        for account in accounts
    ]

    return AccountResponse(
        isSuccess=True, msg="Account fetched successfully", account=account_list
    ).dict()  # Convert to dictionary


async def add_new_account(db: Session, account_data: AccountCreate):
    # Check if the account already exists
    existing_account = (
        db.query(Account)
        .filter(
            Account.user_id == account_data.user_id,
            Account.account_number == account_data.account_number,
        )
        .first()
    )

    if existing_account:
        raise HTTPException(
            status_code=400,
            detail="Account id with this account number already exists.",
        )

    # Create a new Account instance
    new_account = Account(
        user_id=account_data.user_id,
        account_type=account_data.account_type,
        bank_name=account_data.bank_name,
        account_name=account_data.account_name,
        account_number=account_data.account_number,
        credit=account_data.credit,
        debit=account_data.debit,
        balance=account_data.balance,
    )

    db.add(new_account)
    db.commit()
    db.refresh(new_account)

    return AccountResponse(
        msg="Account Created successfully",
        account=[
            AccountDetails(
                id=new_account.id,
                user_id=new_account.user_id,
                account_type=new_account.account_type,
                name=new_account.bank_name,
                holderName=new_account.account_name,
                accountNumber=new_account.account_number,
                balance=new_account.balance,
                credit=new_account.credit,
                debit=new_account.debit,
            )
        ],
    )


async def update_account(db: Session, account_data: AccountDetails):
    account = db.query(Account).filter(Account.id == account_data.id).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found.")

    # Update the fields as needed
    if account_data.user_id:
        account.user_id = account_data.user_id
    if account_data.name:
        account.bank_name = account_data.name
    if account_data.holderName:
        account.account_name = account_data.holderName
    if account_data.accountNumber:
        account.account_number = account_data.accountNumber
    if account_data.balance:
        account.balance = account_data.balance
    if account_data.credit:
        account.credit = account_data.credit
    if account_data.debit:
        account.debit = account_data.debit
    if account_data.account_type:
        account.account_type = account_data.account_type

    db.commit()
    db.refresh(account)

    account = db.query(Account).filter(Account.id == account_data.id).first()

    return AccountResponse(
        msg="Account Updated successfully",
        account=[
            AccountDetails(
                id=account.id,
                user_id=account.user_id,
                account_type=account.account_type,
                name=account.bank_name,
                holderName=account.account_name,
                accountNumber=account.account_number,
                balance=account.balance,
                credit=account.credit,
                debit=account.debit,
            )
        ],
    )


async def delete_account(db: Session, account_id: int):
    account = db.query(Account).filter(Account.id == account_id).first()

    if not account:
        raise HTTPException(status_code=404, detail="Account not found.")

    db.delete(account)
    db.commit()

    return AccountResponse(msg="Account Deleted Successfully")
