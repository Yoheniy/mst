# src/routes/utils/helpers.py
from typing import Dict, Optional
import re
import time

import random
# ============================================================================
# LOGIN ATTEMPT TRACKING
# ============================================================================
login_attempts = {}

def is_ip_locked(ip: str) -> bool:
    """Check if IP is locked due to too many failed login attempts"""
    if ip not in login_attempts:
        return False
    
    attempt_data = login_attempts[ip]
    if "locked_until" in attempt_data and attempt_data["locked_until"] > time.time():
        return True
    
    if "locked_until" in attempt_data and attempt_data["locked_until"] <= time.time():
        del login_attempts[ip]
    
    return False

def record_failed_login(ip: str):
    """Record a failed login attempt"""
    if ip not in login_attempts:
        login_attempts[ip] = {"count": 0, "last_attempt": time.time()}
    
    login_attempts[ip]["count"] += 1
    login_attempts[ip]["last_attempt"] = time.time()
    
    if login_attempts[ip]["count"] >= 5:
        login_attempts[ip]["locked_until"] = time.time() + 900  # 15 minutes

def record_successful_login(ip: str):
    """Record a successful login and reset attempts"""
    if ip in login_attempts:
        del login_attempts[ip]

def get_remaining_attempts(ip: str) -> int:
    """Get remaining login attempts for an IP"""
    if ip not in login_attempts:
        return 5
    return max(0, 5 - login_attempts[ip]["count"])

def get_lockout_time_remaining(ip: str) -> Optional[int]:
    """Get remaining lockout time in seconds"""
    if ip not in login_attempts or "locked_until" not in login_attempts[ip]:
        return None
    
    remaining = login_attempts[ip]["locked_until"] - time.time()
    return max(0, int(remaining))

# ============================================================================
# PASSWORD VALIDATION
# ============================================================================
def validate_password_strength(password: str) -> Dict[str, bool]:
    """Validate password strength and return detailed feedback"""
    validation = {
        "length": len(password) >= 6,
        "lowercase": bool(re.search(r'[a-z]', password)),
        "digit": bool(re.search(r'\d', password)),
    }
    validation["strong"] = all(validation.values())
    return validation

def is_password_strong_enough(password: str) -> bool:
    """Check if password meets minimum security requirements"""
    validation = validate_password_strength(password)
    return sum(validation.values()) >= 4

def get_password_recommendations(password: str) -> list:
    """Get password improvement recommendations"""
    validation = validate_password_strength(password)
    recommendations = []
    
    if not validation["length"]:
        recommendations.append("Use at least 8 characters")
    if not validation["uppercase"]:
        recommendations.append("Include uppercase letters")
    if not validation["lowercase"]:
        recommendations.append("Include lowercase letters")
    if not validation["digit"]:
        recommendations.append("Include numbers")
    if not validation["special"]:
        recommendations.append("Include special characters")
    
    return recommendations

def calculate_password_score(password: str) -> int:
    """Calculate password strength score (0-5)"""
    validation = validate_password_strength(password)
    return sum(validation.values()) - 1  # 0-4 score

# ============================================================================
# EMAIL VALIDATION
# ============================================================================
def is_valid_email(email: str) -> bool:
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def sanitize_email(email: str) -> str:
    """Sanitize email by converting to lowercase and trimming whitespace"""
    return email.lower().strip()

# ============================================================================
# PHONE NUMBER VALIDATION
# ============================================================================
def is_valid_phone_number(phone: str) -> bool:
    """Validate phone number format (basic validation)"""
    # Remove all non-digit characters
    digits_only = re.sub(r'\D', '', phone)
    # Check if it's between 10-15 digits
    return 10 <= len(digits_only) <= 15

def format_phone_number(phone: str) -> str:
    """Format phone number for consistent storage"""
    # Remove all non-digit characters
    digits_only = re.sub(r'\D', '', phone)
    # Basic formatting (you can customize this)
    if len(digits_only) == 10:
        return f"({digits_only[:3]}) {digits_only[3:6]}-{digits_only[6:]}"
    return digits_only

# ============================================================================
# STRING UTILITIES
# ============================================================================
def sanitize_string(text: str, max_length: int = 255) -> str:
    """Sanitize string by trimming and limiting length"""
    if not text:
        return ""
    return text.strip()[:max_length]

def generate_safe_filename(original_name: str) -> str:
    """Generate a safe filename from original name"""
    # Remove special characters and spaces
    safe_name = re.sub(r'[^a-zA-Z0-9._-]', '_', original_name)
    # Remove multiple consecutive underscores
    safe_name = re.sub(r'_+', '_', safe_name)
    # Remove leading/trailing underscores
    safe_name = safe_name.strip('_')
    return safe_name

# ============================================================================
# DATE/TIME UTILITIES
# ============================================================================
def is_valid_date_format(date_string: str, format: str = "%Y-%m-%d") -> bool:
    """Check if date string is in valid format"""
    try:
        from datetime import datetime
        datetime.strptime(date_string, format)
        return True
    except ValueError:
        return False

def get_age_from_birthdate(birthdate) -> Optional[int]:
    """Calculate age from birthdate"""
    try:
        from datetime import date
        today = date.today()
        age = today.year - birthdate.year
        if today.month < birthdate.month or (today.month == birthdate.month and today.day < birthdate.day):
            age -= 1
        return age
    except:
        return None

# ============================================================================
# SEARCH UTILITIES
# ============================================================================
def create_search_filter(search_term: str, fields: list) -> str:
    """Create a search filter for database queries"""
    if not search_term:
        return ""
    
    # Escape special characters for SQL LIKE
    escaped_term = search_term.replace('%', '\\%').replace('_', '\\_')
    return f"%{escaped_term}%"

def normalize_search_term(search_term: str) -> str:
    """Normalize search term for better matching"""
    if not search_term:
        return ""
    
    # Convert to lowercase and remove extra whitespace
    normalized = search_term.lower().strip()
    # Remove multiple spaces
    normalized = re.sub(r'\s+', ' ', normalized)
    return normalized

def generate_8_digit_password() -> str:
    return ''.join(str(random.randint(0, 9)) for _ in range(8))

def generate_4_digit_code() -> str:
    return ''.join(str(random.randint(0, 9)) for _ in range(4))