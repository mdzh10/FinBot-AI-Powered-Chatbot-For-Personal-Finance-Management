from sqlalchemy.orm import Session
from models.account import Account
from schemas.account_schema import AccountResponse, AccountDetails
from typing import List

async def get_all_accounts(db: Session, user_id: int) -> AccountResponse:
    # Fetch all accounts for the given user
    accounts = db.query(Account).filter(Account.user_id == user_id).all()

    if not accounts:
        return AccountResponse(isSuccess=False, msg="No accounts found", accounts=[]).dict()  # Ensure dict conversion

    # Prepare the account list based on the specified structure
    account_list = [
        AccountDetails(
            id=account.id,
            name=account.account_name,
            holderName=account.account_name,
            accountNumber=str(account.account_number),
            balance=account.balance,
            credit=account.credit,
            debit=account.debit
        ) for account in accounts
    ]

    return AccountResponse(
        isSuccess=True,
        msg="Account fetched successfully",
        account=account_list
    ).dict()  # Convert to dictionary
