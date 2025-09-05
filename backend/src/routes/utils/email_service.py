import os
import smtplib
from email.mime.text import MIMEText
from fastapi import HTTPException,status
from dotenv import load_dotenv
from .helpers import generate_8_digit_password


load_dotenv()



smtp_server = os.getenv("SMTP_SERVER")
smtp_port = os.getenv("SMTP_PORT")
smtp_user = os.getenv("SMTP_USER")
smtp_password=os.getenv("SMTP_PASSWORD")
def send_email(recipient_email: str,data) -> str:
    try:
        subject = data['subject']
        body =data['body']

        msg = MIMEText(body)
        msg["Subject"] = subject
        msg["From"] = smtp_user
        msg["To"] = recipient_email
        print(recipient_email,smtp_password)
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.sendmail(smtp_user, recipient_email, msg.as_string())
        return True
    except Exception as e:
       return False

