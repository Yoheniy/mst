# src/model/models.py

# Import all models from separate files
from .enums import *
from .user import *
from .machine import *
from .error_code import *
from .knowledge_base_content import *
from .anomaly_report import *
from .ticket import *
from .chat_conversation import *
from .chat_session import *
from .machine_model import *
from .employee import *
from .document import *
from .document import *

# Import Document model from knowledge_base if it exists
try:
    from .knowledge_base import Document
except ImportError:
    pass
