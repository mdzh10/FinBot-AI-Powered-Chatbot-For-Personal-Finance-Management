from sqlalchemy.orm import Session
from models.account import Account
from schemas.account_schema import AccountResponse, AccountDetails
from typing import List

async def get_all_accounts(db: Session, user_id: int) -> AccountResponse:
    # Fetch all accounts for the given user
    accounts = db.query(Account).filter(Account.user_id == user_id).all()

    if not accounts:
        return AccountResponse(isSuccess=False, msg="No accounts found", accounts=[])

    # Prepare the account list based on the specified structure
    account_list = []
    for account in accounts:
        account_list.append(AccountDetails(
            id=account.id,
            name=account.account_name,           # Assuming account_name as 'name'
            holderName=account.account_name,      # Using account_name as 'holderName'
            accountNumber=str(account.account_number),  # Convert account number to string
            balance=account.balance,
            credit=account.credit,
            debit=account.debit
        ))

    return AccountResponse(
        isSuccess=True,
        msg="Account fetched successfully",
        accounts=account_list
    )