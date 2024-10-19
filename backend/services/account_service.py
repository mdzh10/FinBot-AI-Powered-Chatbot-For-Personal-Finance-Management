from sqlalchemy.orm import Session
from models.account import Account
from schemas.account_schema import AccountResponse
from typing import List

async def get_all_accounts(db: Session, user_id: int) -> List[AccountResponse]:
    # Fetch all accounts for the given user
    accounts = db.query(Account).filter(Account.user_id == user_id).all()

    if not accounts:
        return None

    # Prepare the account responses
    account_list = []
    for account in accounts:
        account_list.append(AccountResponse(
            id=account.id,
            user_id=account.user_id,
            account_type=account.account_type,
            bank_name=account.bank_name,
            account_name=account.account_name,
            account_number=account.account_number,
            balance=account.balance
        ))

    return account_list
