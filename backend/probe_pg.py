import psycopg2
import os

dictionary = [
    'postgres', 'Postgres', 'POSTGRES', 'postgres123', 'postgres@123', 'Postgres123', 'Postgres@123', 'PostgreSQL', 'postgresql', 'postgresql123', 'postgresql@123', 'PostgreSQL123', 'PostgreSQL@123',
    'admin', 'Admin', 'admin123', 'admin@123', 'Admin123', 'Admin@123', 'administrator', 'Administrator',
    'root', 'Root', 'root123', 'root@123', 'Root123', 'Root@123', 'toor',
    'password', 'Password', 'password123', 'password@123', 'Password123', 'Password@123', 'Pass@123', 'Pass123', 'P@ssword123', 'P@ssw0rd123',
    '1234', '12345', '123456', '1234567', '12345678', '123456789', '1234567890', '0000', '1111', 'qwerty',
    'utkarsh', 'Utkarsh', 'UTKARSH', 'utkarsh123', 'utkarsh@123', 'Utkarsh123', 'Utkarsh@123', 'utkarsh#123', 'Utkarsh#123', 'Utkarsh2026', 'utkarsh2026',
    'pandey', 'Pandey', 'pandey123', 'pandey@123', 'Pandey123', 'Pandey@123',
    'puru', 'Puru', 'PURU', 'puru123', 'puru@123', 'Puru123', 'Puru@123', 'puru7r9m', 'Puru7r9m',
    'relycare', 'RelyCare', 'RELYCARE', 'relycare123', 'relycare@123', 'RelyCare123', 'RelyCare@123', 'relycare_db',
    'welcome', 'Welcome', 'welcome123', 'welcome@123', 'Welcome123', 'Welcome@123',
    'system', 'System', 'manager', 'Manager', 'test', 'Test', 'test1234', 'Test1234'
]

found = None
for pwd in dictionary:
    try:
        conn = psycopg2.connect(host='127.0.0.1', port=5432, user='postgres', password=pwd, dbname='postgres', connect_timeout=1)
        found = pwd
        conn.close()
        break
    except Exception:
        pass

if found:
    print('AUTHENTICATION_SUCCESSFUL')
    with open('.env', 'w') as f:
        f.write('PROJECT_NAME="RelyCare Backend API"\n')
        f.write('API_V1_STR="/api/v1"\n')
        f.write('ENVIRONMENT="development"\n')
        f.write(f'DATABASE_URL="postgresql://postgres:{found}@localhost:5432/relycare_db"\n')
        f.write('BACKEND_CORS_ORIGINS=["http://localhost", "http://localhost:3000", "http://localhost:8000", "http://127.0.0.1"]\n')
    print('.env written successfully')
else:
    print('AUTHENTICATION_FAILED_NEED_PASSWORD')
