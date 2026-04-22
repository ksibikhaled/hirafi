@echo off
echo === Testing all accounts ===
echo.
echo --- USER login ---
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d @login_user.json
echo.
echo.
echo --- ADMIN login ---
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d @login_admin.json
echo.
echo.
echo --- ARTISAN login ---
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d @login_artisan.json
echo.
