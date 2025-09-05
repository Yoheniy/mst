# Manufacturing Support Backend API

A comprehensive FastAPI backend for manufacturing equipment support, featuring error code management, knowledge base content, and Cloudinary file storage integration.

## Features

- **Error Code Management**: Complete CRUD operations for manufacturing error codes
- **Knowledge Base**: Content management with file uploads to Cloudinary
- **File Storage**: Secure file handling for images, videos, and documents
- **Authentication**: JWT-based authentication system
- **Database**: PostgreSQL with SQLModel ORM
- **API Documentation**: Auto-generated OpenAPI/Swagger documentation

## Prerequisites

- Python 3.8+
- PostgreSQL database
- Cloudinary account
- Virtual environment (recommended)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   Create a `.env` file in the backend directory with the following variables:
   ```env
   # Database Configuration
   DATABASE_URL=postgresql://username:password@localhost:5432/database_name
   
   # JWT Configuration
   JWT_SECRET_KEY=your-super-secret-jwt-key-here
   JWT_ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   
   # Cloudinary Configuration
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   
   # Application Configuration
   APP_NAME=Manufacturing Support Backend
   DEBUG=True
   ENVIRONMENT=development
   ```

5. **Set up database**
   ```bash
   # Run database migrations
   alembic upgrade head
   ```

6. **Run the application**
   ```bash
   uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
   ```

## API Endpoints

### Error Codes (`/error-codes`)

- `POST /` - Create new error code
- `GET /` - List all error codes with filtering and pagination
- `GET /{error_code_id}` - Get error code by ID
- `GET /code/{code}` - Get error code by code string
- `PUT /{error_code_id}` - Update error code
- `DELETE /{error_code_id}` - Delete error code
- `POST /bulk` - Create multiple error codes
- `GET /manufacturer/{manufacturer_origin}` - Filter by manufacturer
- `GET /severity/{severity}` - Filter by severity level

### Knowledge Base (`/knowledge-base`)

- `POST /` - Create content with file upload
- `GET /` - List all content with filtering
- `GET /{kb_id}` - Get content by ID
- `PUT /{kb_id}` - Update content and files
- `DELETE /{kb_id}` - Delete content and files
- `POST /{kb_id}/upload-file` - Upload file for existing content
- `GET /type/{content_type}` - Get content by type
- `GET /search/tags` - Search by tags
- `GET /stats/summary` - Get content statistics

## File Upload Support

The API supports various file types through Cloudinary integration:

### Supported File Types

- **Images**: JPG, JPEG, PNG, GIF, WebP, BMP, TIFF
- **Videos**: MP4, AVI, MOV, WMV, FLV, WebM, MKV
- **Documents**: PDF, DOC, DOCX, TXT, RTF, ODT

### File Size Limits

- Images: 5MB
- Documents: 25MB
- Videos: 50MB

### Cloudinary Integration

Files are automatically uploaded to Cloudinary with:
- Organized folder structure
- Unique naming to prevent conflicts
- Automatic format detection
- Secure URL generation
- Optional image transformations

## Authentication

All endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Database Models

The system includes comprehensive models for:
- Users (customers, admins, technicians, sales agents)
- Machines and equipment
- Error codes with severity and manufacturer origin
- Knowledge base content with file attachments
- Support tickets and anomaly reports
- Chat conversations

## Error Handling

The API provides comprehensive error handling:
- HTTP status codes for different error types
- Detailed error messages
- Validation errors for input data
- Database constraint violations
- File upload failures

## Development

### Running Tests
```bash
pytest
```

### Code Formatting
```bash
black src/
isort src/
```

### Database Migrations
```bash
# Create new migration
alembic revision --autogenerate -m "Description"

# Apply migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1
```

## Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Yes | - |
| `JWT_SECRET_KEY` | Secret key for JWT tokens | Yes | - |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | Yes | - |
| `CLOUDINARY_API_KEY` | Cloudinary API key | Yes | - |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | Yes | - |
| `DEBUG` | Enable debug mode | No | False |
| `ENVIRONMENT` | Application environment | No | development |

## API Documentation

Once the application is running, visit:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.
