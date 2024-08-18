`from django.shortcuts import render, redirect
import mysql.connector as sql
from django.views.decorators.csrf import csrf_protect
from joblib import load
import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder


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

#loading model
model = load('./predictionModel/model.joblib')
preprocessor = load('./predictionModel/preprocessor.joblib')

# # Utility function to get feature names from ColumnTransformer
# def get_feature_names(preprocessor):
#     feature_names = []
#     if isinstance(preprocessor, ColumnTransformer):
#         for name, transformer, columns in preprocessor.transformers_:
#             if hasattr(transformer, 'get_feature_names_out'):
#                 feature_names.extend(transformer.get_feature_names_out())
#             elif isinstance(transformer, OneHotEncoder):
#                 feature_names.extend(transformer.get_feature_names_out(input_features=columns))
#             else:
#                 feature_names.extend(columns)
#     return feature_names

def predictor(request):
    return render(request, 'form.html')

def formInfo(request):
    try:
        # Getting form data with default values if missing
        education = request.POST.get('education', 'Not Graduate').strip()  # Default value added
        self_employed = request.POST.get('employment', 'No').strip()  # Default value added
        loan_amount = float(request.POST.get('Loanamount', 0))
        loan_term = float(request.POST.get('Loanterm', 0))
        no_of_dependents = float(request.POST.get('dependers', 0))
        cibil_score = float(request.POST.get('credit', 0))
        income_annum = float(request.POST.get('annualIncome', 0))
        residential_assets_value = float(request.POST.get('residentialAsset', 0))
        commercial_assets_value = float(request.POST.get('commercialAsset', 0))
        luxury_assets_value = float(request.POST.get('luxuryAsset', 0))
        bank_asset_value = float(request.POST.get('bankAsset', 0))
        
        print(f"education: {education}")
        print(f"self_employed: {self_employed}")

        

        # Preparing the input DataFrame 
        input_data = pd.DataFrame([[
            no_of_dependents,
            education,
            self_employed,
            income_annum,
            loan_amount,
            loan_term,
            cibil_score,
            residential_assets_value,
            commercial_assets_value,
            luxury_assets_value,
            bank_asset_value
        ]], columns=[
            ' no_of_dependents',
            ' education',
            ' self_employed',
            ' income_annum',
            ' loan_amount',
            ' loan_term',
            ' cibil_score',
            ' residential_assets_value',
            ' commercial_assets_value',
            ' luxury_assets_value',
            ' bank_asset_value'
        ])

        # Get the column order expected by the preprocessor
        # expected_columns = get_feature_names(preprocessor)

        # # Ensure all expected columns are present in input_data
        # for col in expected_columns:
        #     if col not in input_data.columns:
        #         input_data[col] = 0  # Add missing columns with default value

        # # Reorder columns to match expected column order
        # input_data = input_data[expected_columns]

        # # Apply preprocessor
        # input_data_transformed = preprocessor.transform(input_data)

        # Make the prediction
        prediction = model.predict(input_data)

        # Convert the prediction into a human-readable format
        prediction_text = "Congratulations, your loan is approved!" if prediction == 1 else "Sorry, your loan application is rejected."

        # Render the result page
        return render(request, 'result.html', {'prediction': prediction_text})

    except Exception as e:
        return render(request, 'result.html', {'prediction': f"An error occurred: {str(e)}"})