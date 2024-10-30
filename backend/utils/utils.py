import re
from sqlalchemy import inspect
from config.db.database import Base, engine

def generate_database_schema():
    """Dynamically generates the database schema description from SQLAlchemy models."""
    inspector = inspect(engine)
    schema = "The database has the following tables:\n\n"

    for table_name in inspector.get_table_names():
        schema += f"1. **{table_name}**:\n"
        for column in inspector.get_columns(table_name):
            column_name = column['name']
            column_type = str(column['type'])
            is_primary = column.get('primary_key', False)
            is_foreign = column.get('foreign_keys')

            # Mark primary key
            pk = "(primary key)" if is_primary else ""
            
            # Check for foreign key
            fk = f"(foreign key to {list(is_foreign)[0].column.table.name})" if is_foreign else ""
            
            # Add column details
            schema += f"    - `{column_name}` ({column_type}) {pk} {fk}\n"
        
        schema += "\n"

    return schema

def extract_sql_code(api_response: str) -> str:
    """
    Extracts SQL code from a response that contains code within triple backticks.
    """
    # Use regex to match content within triple backticks with "sql" annotation
    match = re.search(r'```sql\n(.*?)\n```', api_response, re.DOTALL)
    if match:
        return match.group(1).strip()  # Extract and strip any extra whitespace
    else:
        raise ValueError("No SQL code found in the API response.")
    
def extract_python_code(api_response: str) -> str:
    """
    Extracts Python code from a response that contains code within triple backticks.
    """
    # Use regex to match content within triple backticks with "python" annotation
    match = re.search(r'```python\n(.*?)\n```', api_response, re.DOTALL)
    if match:
        return match.group(1).strip()  # Extract and strip any extra whitespace
    else:
        raise ValueError("No Python code found in the API response.")
    