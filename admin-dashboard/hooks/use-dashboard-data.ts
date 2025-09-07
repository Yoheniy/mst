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

        // Fetch aggregated statistics in a single request
        const statisticsResponse = await apiClient.getStatistics()

        if (statisticsResponse.error) {
          throw new Error(`Failed to fetch statistics: ${statisticsResponse.error}`)
        }

        const totals = statisticsResponse.data || {}

        const totalUsersCount = Array.isArray(totals.total_users) ? totals.total_users.length : (totals.total_users ?? 0)
        const totalMachinesCount = Array.isArray(totals.total_machines) ? totals.total_machines.length : (totals.total_machines ?? 0)
        const totalKbCount = Array.isArray(totals.total_knowledge_base_content) ? totals.total_knowledge_base_content.length : (totals.total_knowledge_base_content ?? 0)
        const totalTicketsCount = Array.isArray(totals.total_tickets) ? totals.total_tickets.length : (totals.total_tickets ?? 0)
        const totalErrorCodesCount = Array.isArray(totals.total_error_codes) ? totals.total_error_codes.length : (totals.total_error_codes ?? 0)

        const stats: DashboardStats = {
          totalUsers: totalUsersCount,
          activeMachines: totalMachinesCount,
          knowledgeArticles: totalKbCount,
          openTickets: totalTicketsCount,
          errorCodes: totalErrorCodesCount,
          usersChange: calculateChange(new Array(totalUsersCount).fill(0)),
          machinesChange: calculateChange(new Array(totalMachinesCount).fill(0)),
          articlesChange: calculateChange(new Array(totalKbCount).fill(0)),
          ticketsChange: calculateChange(new Array(totalTicketsCount).fill(0)),
        }

        setData({
          users: [],
          machines: [],
          knowledgeBase: [],
          errorCodes: [],
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
