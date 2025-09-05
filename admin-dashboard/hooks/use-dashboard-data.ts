import { useState, useEffect } from 'react'
import { apiClient } from '@/lib/api-client'
import { User, Machine, KnowledgeBaseContent, ErrorCode } from '@/lib/api-client'

export interface DashboardStats {
  totalUsers: number
  activeMachines: number
  knowledgeArticles: number
  openTickets: number
  errorCodes: number
  usersChange: number
  machinesChange: number
  articlesChange: number
  ticketsChange: number
}

export interface DashboardData {
  users: User[]
  machines: Machine[]
  knowledgeBase: KnowledgeBaseContent[]
  errorCodes: ErrorCode[]
  stats: DashboardStats
}

export function useDashboardData() {
  const [data, setData] = useState<DashboardData | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        setIsLoading(true)
        setError(null)

        // Fetch all data in parallel
        const [
          usersResponse,
          machinesResponse,
          knowledgeResponse,
          errorCodesResponse
        ] = await Promise.all([
          apiClient.getUsers(),
          apiClient.getMachines(),
          apiClient.getKnowledgeBase(),
          apiClient.getErrorCodes()
        ])

        // Check for errors
        if (usersResponse.error) {
          throw new Error(`Failed to fetch users: ${usersResponse.error}`)
        }
        if (machinesResponse.error) {
          throw new Error(`Failed to fetch machines: ${machinesResponse.error}`)
        }
        if (knowledgeResponse.error) {
          throw new Error(`Failed to fetch knowledge base: ${knowledgeResponse.error}`)
        }
        if (errorCodesResponse.error) {
          throw new Error(`Failed to fetch error codes: ${errorCodesResponse.error}`)
        }

        // Calculate stats
        const stats: DashboardStats = {
          totalUsers: usersResponse.data?.length || 0,
          activeMachines: machinesResponse.data?.length || 0,
          knowledgeArticles: knowledgeResponse.data?.length || 0,
          openTickets: 0, // TODO: Implement tickets API
          errorCodes: errorCodesResponse.data?.length || 0,
          usersChange: calculateChange(usersResponse.data || []),
          machinesChange: calculateChange(machinesResponse.data || []),
          articlesChange: calculateChange(knowledgeResponse.data || []),
          ticketsChange: 0, // TODO: Implement tickets API
        }

        setData({
          users: usersResponse.data || [],
          machines: machinesResponse.data || [],
          knowledgeBase: knowledgeResponse.data || [],
          errorCodes: errorCodesResponse.data || [],
          stats
        })

      } catch (err) {
        console.error('Error fetching dashboard data:', err)
        setError(err instanceof Error ? err.message : 'Failed to fetch dashboard data')
      } finally {
        setIsLoading(false)
      }
    }

    fetchDashboardData()
  }, [])

  return {
    data,
    stats: data?.stats,
    users: data?.users,
    machines: data?.machines,
    knowledgeBase: data?.knowledgeBase,
    errorCodes: data?.errorCodes,
    isLoading,
    error
  }
}

// Helper function to calculate change percentage (mock implementation)
function calculateChange<T>(items: T[]): number {
  // This is a mock implementation - in a real app, you'd compare with previous period
  const baseCount = Math.max(items.length, 1)
  const change = Math.floor(Math.random() * 20) - 10 // Random change between -10 and +10
  return change
}

// Individual data hooks for specific sections
export function useUsers() {
  const [users, setUsers] = useState<User[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setIsLoading(true)
        const response = await apiClient.getUsers()
        
        if (response.error) {
          throw new Error(response.error)
        }
        
        setUsers(response.data || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch users')
      } finally {
        setIsLoading(false)
      }
    }

    fetchUsers()
  }, [])

  return { users, isLoading, error }
}

export function useMachines() {
  const [machines, setMachines] = useState<Machine[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchMachines = async () => {
      try {
        setIsLoading(true)
        const response = await apiClient.getMachines()
        
        if (response.error) {
          throw new Error(response.error)
        }
        
        setMachines(response.data || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch machines')
      } finally {
        setIsLoading(false)
      }
    }

    fetchMachines()
  }, [])

  return { machines, isLoading, error }
}

export function useKnowledgeBase() {
  const [knowledgeBase, setKnowledgeBase] = useState<KnowledgeBaseContent[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchKnowledgeBase = async () => {
      try {
        setIsLoading(true)
        const response = await apiClient.getKnowledgeBase()
        
        if (response.error) {
          throw new Error(response.error)
        }
        
        setKnowledgeBase(response.data || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch knowledge base')
      } finally {
        setIsLoading(false)
      }
    }

    fetchKnowledgeBase()
  }, [])

  return { knowledgeBase, isLoading, error }
}

export function useErrorCodes() {
  const [errorCodes, setErrorCodes] = useState<ErrorCode[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchErrorCodes = async () => {
      try {
        setIsLoading(true)
        const response = await apiClient.getErrorCodes()
        
        if (response.error) {
          throw new Error(response.error)
        }
        
        setErrorCodes(response.data || [])
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch error codes')
      } finally {
        setIsLoading(false)
      }
    }

    fetchErrorCodes()
  }, [])

  return { errorCodes, isLoading, error }
}
