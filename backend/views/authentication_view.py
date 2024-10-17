def user_register_response(user, is_success=True, msg="Operation successful"):
    return {
        "isSuccess": is_success,
        "msg": msg,
        "user_id": user.user_id if user else None,
        "email": user.email if user else None,
        "username": user.username if user else None,
        "phone_number": user.phone_number if user else None
    }

def success_login_response(db_user, access_token):
    return {
        "isSuccess": True,
        "msg": "Login successful",
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": db_user.user_id,
        "email": db_user.email,
        "username": db_user.username,
        "phone_number": db_user.phone_number
    }

def error_response(is_success=False, msg="Operation failed"):
    return {
        "isSuccess": is_success,
        "msg": msg,
        "user_id": None,
        "email": None,
        "username": None,
        "phone_number": None
    }
