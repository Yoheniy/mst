from enum import Enum

# --- Enums ---
class UserRole(str, Enum):
    CUSTOMER = "customer"
    ADMIN = "admin"
    TECHNICIAN = "technician"
    SALES_AGENT = "sales_agent"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class TicketStatus(str, Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"
    ESCALATED = "escalated"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class TicketPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class ContentType(str, Enum):
    document = "document"
    faq = "faq"
    troubleshooting_guide = "troubleshooting_guide"
    video = "video"
    tutorial = "tutorial"
    error_guide = "error_guide"
    image = "image"

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            return cls(value.lower())
        return None


class AnomalyStatus(str, Enum):
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    KB_INCORPORATED = "kb_incorporated"
    CLOSED = "closed"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class AnomalyPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class ErrorSeverity(str, Enum):
    MINOR = "minor"
    WARNING = "warning"
    CRITICAL = "critical"

    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class ManufacturerOrigin(str, Enum):
    MACHINE = "machine"
    CHILLER = "chiller"
    LASER_SOURCE = "laser_source"
    DRIVE = "drive"
    CONTROLLER = "controller"
    SOFTWARE = "software"
    OTHER = "other"
    
    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None

class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"
    
    @classmethod
    def _missing_(cls, value):
        # Handle case-insensitive matching
        if isinstance(value, str):
            for member in cls:
                if member.value.upper() == value.upper():
                    return member
        return None