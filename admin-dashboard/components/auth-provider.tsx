"use client"

import type React from "react"

import { createContext, useContext, useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import { apiClient } from "@/lib/api-client"

interface User {
  email: string
  role: string
  name: string
  loginTime: string
}

interface AuthContextType {
  user: User | null
  login: (user: User) => void
  logout: () => void
  isLoading: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()
  const pathname = usePathname()

  useEffect(() => {
    console.log("[v0] AuthProvider: Checking for existing session")
    // Check for existing session
    const storedUser = localStorage.getItem("adminUser")
    const accessToken = localStorage.getItem("access_token")
    
    if (storedUser && accessToken) {
      try {
        const userData = JSON.parse(storedUser)
        console.log("[v0] AuthProvider: Found stored user:", userData.name)
        
        // Verify token is still valid by fetching profile
        apiClient.getProfile().then((response) => {
          if (response.error) {
            console.log("[v0] AuthProvider: Token invalid, clearing session")
            localStorage.removeItem("adminUser")
            localStorage.removeItem("access_token")
            setUser(null)
          } else {
            console.log("[v0] AuthProvider: Token valid, setting user")
            setUser(userData)
          }
          setIsLoading(false)
        }).catch(() => {
          console.log("[v0] AuthProvider: Error verifying token, clearing session")
          localStorage.removeItem("adminUser")
          localStorage.removeItem("access_token")
          setUser(null)
          setIsLoading(false)
        })
      } catch (error) {
        console.log("[v0] AuthProvider: Error parsing stored user, removing")
        localStorage.removeItem("adminUser")
        localStorage.removeItem("access_token")
        setIsLoading(false)
      }
    } else {
      console.log("[v0] AuthProvider: No stored user or token found")
      setIsLoading(false)
    }
  }, [])

  useEffect(() => {
    console.log("[v0] AuthProvider: Redirect logic - user:", !!user, "loading:", isLoading, "pathname:", pathname)
    // Redirect logic
    if (!isLoading) {
      if (!user && pathname !== "/login") {
        console.log("[v0] AuthProvider: Redirecting to login")
        router.push("/login")
      } else if (user && pathname === "/login") {
        console.log("[v0] AuthProvider: User logged in, redirecting to dashboard")
        router.push("/")
      }
    }
  }, [user, isLoading, pathname, router])

  const login = (userData: User) => {
    console.log("[v0] AuthProvider: Login called for:", userData.name)
    setUser(userData)
    localStorage.setItem("adminUser", JSON.stringify(userData))
    router.push("/")
  }

  const logout = async () => {
    console.log("[v0] AuthProvider: Logout called")
    
    // Call logout API
    try {
      await apiClient.logout()
    } catch (error) {
      console.log("[v0] AuthProvider: Logout API call failed, continuing with local logout")
    }
    
    // Clear local storage
    setUser(null)
    localStorage.removeItem("adminUser")
    localStorage.removeItem("access_token")
    router.push("/login")
  }

  return <AuthContext.Provider value={{ user, login, logout, isLoading }}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}
