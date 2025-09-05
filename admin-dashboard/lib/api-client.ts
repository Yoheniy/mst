import { API_CONFIG, buildApiUrl } from './config'

// Types for API responses
export interface ApiResponse<T = any> {
  data?: T
  message?: string
  error?: string
  status: number
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  access_token: string
  token_type: string
  expires_in: number
  user: {
    user_id: number
    email: string
    full_name: string
    role: string
    company_name?: string
  }
}

export interface User {
  user_id: number
  email: string
  full_name: string
  role: string
  company_name?: string
  phone_number?: string
  employee_id?: string
  created_at?: string
  updated_at?: string
}

export interface Machine {
  machine_id: number
  serial_number: string
  model: string
  type: string
  purchase_date?: string
  warranty_end_date?: string
  location?: string
  owner_id: number
  created_at: string
  updated_at: string
}

export interface KnowledgeBaseContent {
  kb_id: number
  title: string
  content_type: string
  content_text?: string
  external_url?: string
  tags?: string[]
  applies_to_models?: string[]
  uploaded_by_user_id: number
  related_error_code_id?: number
  created_at: string
  updated_at: string
}

export interface ErrorCode {
  error_code_id: number
  code: string
  title: string
  description?: string
  manufacturer_origin?: string
  severity?: string
  suggested_action?: string
  created_at: string
  updated_at: string
}

export interface Ticket {
  id: string
  title: string
  description: string
  status: 'open' | 'in_progress' | 'resolved' | 'closed'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  assigned_to?: string
  created_at: string
  updated_at: string
}

export interface MachineModelDto {
  serial_number: string
  model?: string
  type?: string
  owned?: boolean
}

// API Client class
class ApiClient {
  private baseUrl: string
  private timeout: number

  constructor() {
    this.baseUrl = API_CONFIG.BASE_URL
    this.timeout = API_CONFIG.TIMEOUT
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = buildApiUrl(endpoint)
    
    const isFormData = options && 'body' in options && options.body instanceof FormData

    const defaultHeaders: Record<string, string> = {}

    // Add JSON content-type only if not multipart
    if (!isFormData) {
      defaultHeaders['Content-Type'] = 'application/json'
    }

    // Add authorization header if token exists
    const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null
    if (token) {
      defaultHeaders['Authorization'] = `Bearer ${token}`
    }

    const mergedHeaders: Record<string, any> = {
      ...defaultHeaders,
      ...(options.headers as any),
    }

    const config: RequestInit = {
      ...options,
      headers: mergedHeaders,
      signal: AbortSignal.timeout(this.timeout),
    }

    try {
      const response = await fetch(url, config)

      // Handle 204 No Content early
      if (response.status === 204) {
        return { status: 204 }
      }

      const contentType = response.headers.get('content-type') || ''
      let data: any
      try {
        if (contentType.includes('application/json')) {
          // Some endpoints may reply with empty body but JSON content-type
          const text = await response.text()
          data = text ? JSON.parse(text) : undefined
        } else {
          data = await response.text()
        }
      } catch (e) {
        // Fallback if parsing fails
        data = undefined
      }

      if (!response.ok) {
        const errMsg = typeof data === 'string' ? data : (data?.detail?.message || data?.detail || data?.message || data?.error || 'An error occurred')
        const errStr = typeof errMsg === 'string' ? errMsg : JSON.stringify(errMsg)
        return {
          status: response.status,
          error: errStr,
          message: typeof data === 'string' ? undefined : (typeof data?.message === 'string' ? data.message : undefined),
        }
      }

      return {
        status: response.status,
        data: typeof data === 'string' ? (undefined as unknown as T) : data,
        message: typeof data === 'string' ? undefined : data?.message,
      }
    } catch (error) {
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          return {
            status: 408,
            error: 'Request timeout',
          }
        }
        return {
          status: 0,
          error: error.message,
        }
      }
      return {
        status: 0,
        error: 'Unknown error occurred',
      }
    }
  }

  // Authentication methods
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    // Convert to form data as expected by the backend
    const formData = new URLSearchParams()
    formData.append('username', credentials.email)
    formData.append('password', credentials.password)
    
    return this.request<LoginResponse>(API_CONFIG.ENDPOINTS.AUTH.LOGIN, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: formData.toString(),
    })
  }

  async logout(): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.AUTH.LOGOUT, {
      method: 'POST',
    })
  }

  async getProfile(): Promise<ApiResponse<User>> {
    return this.request<User>(API_CONFIG.ENDPOINTS.AUTH.PROFILE)
  }

  // User methods
  async getUsers(): Promise<ApiResponse<User[]>> {
    return this.request<User[]>(API_CONFIG.ENDPOINTS.USERS.LIST)
  }

  async getUser(id: string): Promise<ApiResponse<User>> {
    return this.request<User>(API_CONFIG.ENDPOINTS.USERS.GET(id))
  }

  async createUser(userData: Partial<User>): Promise<ApiResponse<User>> {
    return this.request<User>(API_CONFIG.ENDPOINTS.USERS.CREATE, {
      method: 'POST',
      body: JSON.stringify(userData),
    })
  }

  async updateUser(id: string, userData: Partial<User>): Promise<ApiResponse<User>> {
    return this.request<User>(API_CONFIG.ENDPOINTS.USERS.UPDATE(id), {
      method: 'PUT',
      body: JSON.stringify(userData),
    })
  }

  async deleteUser(id: string): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.USERS.DELETE(id), {
      method: 'DELETE',
    })
  }

  // Machine methods
  async getMachines(): Promise<ApiResponse<Machine[]>> {
    return this.request<Machine[]>(API_CONFIG.ENDPOINTS.MACHINES.LIST)
  }

  async getMyMachines(): Promise<ApiResponse<Machine[]>> {
    return this.request<Machine[]>(API_CONFIG.ENDPOINTS.MACHINES.MY_MACHINES)
  }

  async getMachine(id: string): Promise<ApiResponse<Machine>> {
    return this.request<Machine>(API_CONFIG.ENDPOINTS.MACHINES.GET(id))
  }

  async createMachine(machineData: Partial<Machine>): Promise<ApiResponse<Machine>> {
    // Backend model currently requires owner_id even though route ignores it
    const payload = { owner_id: 0, ...machineData }
    return this.request<Machine>(API_CONFIG.ENDPOINTS.MACHINES.CREATE, {
      method: 'POST',
      body: JSON.stringify(payload),
    })
  }

  async updateMachine(id: string, machineData: Partial<Machine>): Promise<ApiResponse<Machine>> {
    return this.request<Machine>(API_CONFIG.ENDPOINTS.MACHINES.UPDATE(id), {
      method: 'PUT',
      body: JSON.stringify(machineData),
    })
  }

  async deleteMachine(id: string): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.MACHINES.DELETE(id), {
      method: 'DELETE',
    })
  }

  // Knowledge Base methods
  async getKnowledgeBase(): Promise<ApiResponse<KnowledgeBaseContent[]>> {
    return this.request<KnowledgeBaseContent[]>(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.LIST)
  }

  async getKnowledgeBaseItem(id: string): Promise<ApiResponse<KnowledgeBaseContent>> {
    return this.request<KnowledgeBaseContent>(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.GET(id))
  }

  async createKnowledgeBaseItem(contentData: Partial<KnowledgeBaseContent> & { file?: File }): Promise<ApiResponse<KnowledgeBaseContent>> {
    // Backend expects multipart/form-data with field `content` (JSON string) and optional `file`
    const { file, ...rest } = contentData as any
    const form = new FormData()
    // Ensure uploader_id is present for pydantic validation (server will override with current user)
    const payload = { uploader_id: 0, ...rest }
    form.append('content', JSON.stringify(payload))
    if (file) form.append('file', file)

    return this.request<KnowledgeBaseContent>(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.CREATE, {
      method: 'POST',
      headers: { },
      body: form as any,
    })
  }

  async updateKnowledgeBaseItem(id: string, contentData: Partial<KnowledgeBaseContent>): Promise<ApiResponse<KnowledgeBaseContent>> {
    return this.request<KnowledgeBaseContent>(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.UPDATE(id), {
      method: 'PUT',
      body: JSON.stringify(contentData),
    })
  }

  async deleteKnowledgeBaseItem(id: string): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.DELETE(id), {
      method: 'DELETE',
    })
  }

  // Error Code methods
  async getErrorCodes(): Promise<ApiResponse<ErrorCode[]>> {
    return this.request<ErrorCode[]>(API_CONFIG.ENDPOINTS.ERROR_CODES.LIST)
  }

  async getErrorCode(id: string): Promise<ApiResponse<ErrorCode>> {
    return this.request<ErrorCode>(API_CONFIG.ENDPOINTS.ERROR_CODES.GET(id))
  }

  async getErrorCodeByCode(code: string): Promise<ApiResponse<ErrorCode>> {
    return this.request<ErrorCode>(API_CONFIG.ENDPOINTS.ERROR_CODES.GET_BY_CODE(code))
  }

  async createErrorCode(errorCodeData: Partial<ErrorCode>): Promise<ApiResponse<ErrorCode>> {
    return this.request<ErrorCode>(API_CONFIG.ENDPOINTS.ERROR_CODES.CREATE, {
      method: 'POST',
      body: JSON.stringify(errorCodeData),
    })
  }

  async updateErrorCode(id: string, errorCodeData: Partial<ErrorCode>): Promise<ApiResponse<ErrorCode>> {
    return this.request<ErrorCode>(API_CONFIG.ENDPOINTS.ERROR_CODES.UPDATE(id), {
      method: 'PUT',
      body: JSON.stringify(errorCodeData),
    })
  }

  async deleteErrorCode(id: string): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.ERROR_CODES.DELETE(id), {
      method: 'DELETE',
    })
  }

  async getErrorCodesByManufacturer(manufacturer: string): Promise<ApiResponse<ErrorCode[]>> {
    return this.request<ErrorCode[]>(API_CONFIG.ENDPOINTS.ERROR_CODES.BY_MANUFACTURER(manufacturer))
  }

  async getErrorCodesBySeverity(severity: string): Promise<ApiResponse<ErrorCode[]>> {
    return this.request<ErrorCode[]>(API_CONFIG.ENDPOINTS.ERROR_CODES.BY_SEVERITY(severity))
  }

  // Ticket methods
  async getTickets(): Promise<ApiResponse<Ticket[]>> {
    return this.request<Ticket[]>(API_CONFIG.ENDPOINTS.TICKETS)
  }

  async getTicket(id: string): Promise<ApiResponse<Ticket>> {
    return this.request<Ticket>(`${API_CONFIG.ENDPOINTS.TICKETS}/${id}`)
  }

  // Analytics methods
  async getAnalytics(): Promise<ApiResponse<any>> {
    return this.request(API_CONFIG.ENDPOINTS.ANALYTICS)
  }

  // Serial number (MachineModel) methods
  async getSerialNumbers(): Promise<ApiResponse<MachineModelDto[]>> {
    return this.request<MachineModelDto[]>(API_CONFIG.ENDPOINTS.SERIAL_NUMBER.LIST)
  }

  async createSerialNumber(data: { serial_number: string; owned?: boolean }): Promise<ApiResponse<MachineModelDto>> {
    const qs = new URLSearchParams()
    qs.append('serial_number', data.serial_number)
    if (typeof data.owned === 'boolean') qs.append('owned', String(data.owned))
    const endpoint = `${API_CONFIG.ENDPOINTS.SERIAL_NUMBER.CREATE}?${qs.toString()}`
    return this.request<MachineModelDto>(endpoint, {
      method: 'POST',
    })
  }

  async deleteSerialNumber(serial: string): Promise<ApiResponse> {
    return this.request(API_CONFIG.ENDPOINTS.SERIAL_NUMBER.DELETE(encodeURIComponent(serial)), {
      method: 'DELETE',
    })
  }

  async getNotOwnedSerialNumbers(): Promise<ApiResponse<MachineModelDto[]>> {
    return this.request<MachineModelDto[]>(API_CONFIG.ENDPOINTS.SERIAL_NUMBER.NOT_OWNED)
  }
}

// Export singleton instance
export const apiClient = new ApiClient()
