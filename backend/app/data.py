from app.auth import hash_password

users = {
    "admin@gmail.com": {
        "email": "admin@gmail.com",
        "password": hash_password("admin123"),
        "role": "Admin"
    },

    "sales@gmail.com": {
        "email": "sales@gmail.com",
        "password": hash_password("sales123"),
        "role": "Sales"
    }
}