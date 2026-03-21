# users/backends.py
from django.core.mail.backends.base import BaseEmailBackend
import sys

class ReadableConsoleEmailBackend(BaseEmailBackend):
    def send_messages(self, email_messages):
        if not email_messages:
            return 0
        
        for message in email_messages:
            sys.stdout.write("\n=================== EMAIL START ===================\n")
            sys.stdout.write(f"Subject: {message.subject}\n")
            sys.stdout.write(f"From: {message.from_email}\n")
            sys.stdout.write(f"To: {', '.join(message.to)}\n")
            sys.stdout.write("---------------------------------------------------\n")
            sys.stdout.write(message.body + "\n")
            sys.stdout.write("==================== EMAIL END ====================\n\n")
            sys.stdout.flush()
            
        return len(email_messages)