// API Configuration
export const API_CONFIG = {
  BASE_URL: 'http://localhost:8000',
  TIMEOUT: parseInt('30000'),
  ENDPOINTS: {
    DASHBOARD: {
      STATISTICS: '/statistics'
    },
    AUTH: {
      LOGIN: '/login',
      LOGOUT: '/logout',
      REFRESH: '/refresh-token',
      PROFILE: '/users/me/'
    },
    USERS: {
      LIST: '/admin/users/',
      CREATE: '/admin/users/',
      GET: (id: string) => `/admin/users/${id}`,
      UPDATE: (id: string) => `/admin/users/${id}`,
      DELETE: (id: string) => `/admin/users/${id}`
    },
    MACHINES: {
      LIST: '/machines',
      MY_MACHINES: '/machines/my-machines',
      GET: (id: string) => `/machines/${id}`,
      CREATE: '/machines',
      UPDATE: (id: string) => `/machines/${id}`,
      DELETE: (id: string) => `/machines/${id}`
    },
    SERIAL_NUMBER: {
      LIST: '/serial-number',
      CREATE: '/serial-number',
      DELETE: (serial: string) => `/serial-number/${serial}`,
      NOT_OWNED: '/serial-number/not-owned'
    },
    KNOWLEDGE_BASE: {
      LIST: '/knowledge-base',
      GET: (id: string) => `/knowledge-base/${id}`,
      CREATE: '/knowledge-base',
      UPDATE: (id: string) => `/knowledge-base/${id}`,
      DELETE: (id: string) => `/knowledge-base/${id}`,
      SEARCH: '/knowledge-base/search/tags',
      STATS: '/knowledge-base/stats/summary'
    },
    ERROR_CODES: {
      LIST: '/error-codes',
      GET: (id: string) => `/error-codes/${id}`,
      GET_BY_CODE: (code: string) => `/error-codes/code/${code}`,
      CREATE: '/error-codes',
      UPDATE: (id: string) => `/error-codes/${id}`,
      DELETE: (id: string) => `/error-codes/${id}`,
      BULK_CREATE: '/error-codes/bulk',
      BY_MANUFACTURER: (manufacturer: string) => `/error-codes/manufacturer/${manufacturer}`,
      BY_SEVERITY: (severity: string) => `/error-codes/severity/${severity}`
    },
    TICKETS: '/tickets',
    ANALYTICS: '/analytics'
  }
} as const

// Helper function to build full API URL
export const buildApiUrl = (endpoint: string): string => {
  return `${API_CONFIG.BASE_URL}${endpoint}`
}
