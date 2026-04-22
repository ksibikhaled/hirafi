@echo off
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d @login_user.json
echo.
echo --- Admin Login ---
curl -s -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d @login_admin.json
