from django.shortcuts import render, redirect
import mysql.connector as sql
from django.views.decorators.csrf import csrf_protect

@csrf_protect
def user_action(request):
    if request.method == "POST":
        m = sql.connect(host="localhost", user="root", password="Infiniti@111", database="user_auth")
        cursor = m.cursor()
        d = request.POST

        # Determine the action based on the form submitted
        action = d.get('action')

        if action == 'Sign Up':
            saveRname = d.get('Rname')
            saveRemail = d.get('Remail')
            saveRpassword = d.get('Rpassword')

            if not saveRname or not saveRemail or not saveRpassword:
                return render(request, 'registerLogin.html', {'error': 'All fields are required'})

            query = "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)"
            try:
                cursor.execute(query, (saveRname, saveRemail, saveRpassword))
                m.commit()
            except sql.Error as e:
                return render(request, 'registerLogin.html', {'error': 'An error occurred: {}'.format(e)})
            finally:
                m.close()

            return redirect('success')

        elif action == 'Sign In':
            login_email = d.get('Lemail')
            login_password = d.get('Lpassword')

            if not login_email or not login_password:
                return render(request, 'registerLogin.html', {'error': 'Email and password are required for login'})

            query = "SELECT * FROM users WHERE email = %s AND password = %s"
            cursor.execute(query, (login_email, login_password))
            user = cursor.fetchone()

            if user:
                return redirect('success')
            else:
                return render(request, 'registerLogin.html', {'error': 'Invalid email or password'})

            m.close()

    return render(request, 'registerLogin.html')

def success_page(request):
    return render(request, 'success.html')
