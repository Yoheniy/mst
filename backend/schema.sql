-- backend/schema.sql - REVISED

-- Drop tables in reverse order to avoid foreign key conflicts during re-creation
DROP TABLE IF EXISTS chat_conversations CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS anomaly_reports CASCADE; -- NEW
DROP TABLE IF EXISTS knowledge_base_content CASCADE;
DROP TABLE IF EXISTS error_codes CASCADE; -- NEW
DROP TABLE IF EXISTS machines CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Users Table (Represents customers, admins, technicians, sales agents)
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    company_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'customer' NOT NULL CHECK (role IN ('customer', 'admin', 'technician', 'sales_agent')), -- Added specific roles
    employee_id VARCHAR(50) UNIQUE, -- Employee-specific identifier, NULL for customers
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 2. Machines Table
CREATE TABLE machines (
    machine_id BIGSERIAL PRIMARY KEY,
    serial_number VARCHAR(255) UNIQUE NOT NULL,
    model VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    purchase_date DATE,
    warranty_end_date DATE,
    user_id BIGINT NOT NULL, -- Owner of the machine (customer)
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. Error Codes Table (NEW!)
CREATE TABLE error_codes (
    error_code_id BIGSERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL, -- e.g., "E123", "CHL-404"
    title VARCHAR(255) NOT NULL,
    description TEXT,
    manufacturer_origin VARCHAR(100), -- e.g., "Machine", "Chiller", "Laser Source"
    severity VARCHAR(50), -- e.g., 'Minor', 'Warning', 'Critical'
    suggested_action TEXT, -- Immediate, concise action
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 4. Knowledge Base Content Table (Revised)
CREATE TABLE knowledge_base_content (
    kb_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    content_text TEXT,
    external_url VARCHAR(500),
    tags JSONB,
    applies_to_models JSONB,
    uploaded_by_user_id BIGINT NOT NULL, -- Can be admin, technician, or sales_agent
    related_error_code_id BIGINT, -- Optional link to an error_code
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    FOREIGN KEY (uploaded_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT, -- Don't delete user if they uploaded content
    FOREIGN KEY (related_error_code_id) REFERENCES error_codes(error_code_id) ON DELETE SET NULL
);

-- 5. Anomaly Reports Table (NEW!)
CREATE TABLE anomaly_reports (
    report_id BIGSERIAL PRIMARY KEY,
    reporter_user_id BIGINT NOT NULL, -- The technician or employee submitting
    machine_id BIGINT NOT NULL,
    report_text TEXT NOT NULL,
    media_urls JSONB, -- Array of URLs to uploaded photos/videos/audio
    audio_transcript TEXT, -- If speech-to-text was used for report_text
    status VARCHAR(50) DEFAULT 'Submitted' NOT NULL CHECK (status IN ('Submitted', 'Under Review', 'KB Incorporated', 'Closed')),
    priority VARCHAR(50) DEFAULT 'Medium' NOT NULL CHECK (priority IN ('Low', 'Medium', 'High')),
    observed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    FOREIGN KEY (reporter_user_id) REFERENCES users(user_id) ON DELETE RESTRICT, -- Don't delete user if they submitted reports
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id) ON DELETE CASCADE
);

-- 6. Tickets Table (Revised)
CREATE TABLE tickets (
    ticket_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL, -- User who submitted the ticket (customer or employee)
    machine_id BIGINT,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'Open' NOT NULL,
    priority VARCHAR(50) DEFAULT 'Medium' NOT NULL,
    escalated_to_agent BOOLEAN DEFAULT FALSE NOT NULL,
    ai_confidence_score DECIMAL(5,2),
    assigned_agent_id BIGINT, -- The admin/technician user assigned
    related_anomaly_report_id BIGINT UNIQUE, -- Optional link if a ticket originated from an anomaly report
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    resolved_at TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (machine_id) REFERENCES machines(machine_id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_agent_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (related_anomaly_report_id) REFERENCES anomaly_reports(report_id) ON DELETE SET NULL
);

-- 7. Chat Conversations Table
CREATE TABLE chat_conversations (
    chat_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    ticket_id BIGINT UNIQUE,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    transcript JSONB NOT NULL, -- Stores rich chat history
    final_resolution TEXT,
    was_escalated BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id) ON DELETE SET NULL
);

-- Add indexes for common lookup fields to improve performance
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_employee_id ON users (employee_id);
CREATE INDEX idx_machines_serial ON machines (serial_number);
CREATE INDEX idx_machines_user_id ON machines (user_id);
CREATE INDEX idx_error_codes_code ON error_codes (code); -- NEW
CREATE INDEX idx_kb_content_uploaded_by ON knowledge_base_content (uploaded_by_user_id);
CREATE INDEX idx_kb_content_related_error ON knowledge_base_content (related_error_code_id); -- NEW
CREATE INDEX idx_anomaly_reports_reporter_user_id ON anomaly_reports (reporter_user_id); -- NEW
CREATE INDEX idx_anomaly_reports_machine_id ON anomaly_reports (machine_id); -- NEW
CREATE INDEX idx_tickets_user_id ON tickets (user_id);
CREATE INDEX idx_tickets_machine_id ON tickets (machine_id);
CREATE INDEX idx_tickets_status ON tickets (status);
CREATE INDEX idx_tickets_assigned_agent_id ON tickets (assigned_agent_id);
CREATE INDEX idx_tickets_related_anomaly_report_id ON tickets (related_anomaly_report_id); -- NEW
CREATE INDEX idx_chat_conversations_user_id ON chat_conversations (user_id);
CREATE INDEX idx_chat_conversations_ticket_id ON chat_conversations (ticket_id);

-- Trigger to update updated_at timestamp on row modification

