from enum import Enum

# --- Enums ---
class UserRole(str, Enum):
    CUSTOMER = "customer"
    ADMIN = "admin"
    TECHNICIAN = "technician"
    SALES_AGENT = "sales_agent"

class TicketStatus(str, Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"
    ESCALATED = "escalated"

class TicketPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

class ContentType(str, Enum):
    DOCUMENT = "document"
    FAQ = "faq"
    TROUBLESHOOTING_GUIDE = "troubleshooting_guide"
    VIDEO = "video"
    TUTORIAL = "tutorial"
    ERROR_GUIDE = "error_guide"

class AnomalyStatus(str, Enum):
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    KB_INCORPORATED = "kb_incorporated"
    CLOSED = "closed"

class AnomalyPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class ErrorSeverity(str, Enum):
    MINOR = "minor"
    WARNING = "warning"
    CRITICAL = "critical"

class ManufacturerOrigin(str, Enum):
    MACHINE = "machine"
    CHILLER = "chiller"
    LASER_SOURCE = "laser_source"
    DRIVE = "drive"
    CONTROLLER = "controller"
    SOFTWARE = "software"
    OTHER = "other"

class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"
