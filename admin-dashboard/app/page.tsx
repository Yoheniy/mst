"use client"

import { Users, Server, BookOpen, Ticket, BarChart3, Settings, AlertTriangle } from "lucide-react"
import { useAuth } from "@/components/auth-provider"
import { useDashboardData } from "@/hooks/use-dashboard-data"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { StatCard } from "@/components/stat-card"
import { ActionCard } from "@/components/action-card"

export default function AdminDashboard() {
  const { user, isLoading } = useAuth()
  const { stats, isLoading: statsLoading, error: statsError } = useDashboardData()

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center">
        <div className="text-center">
          <div className="relative">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-blue-200 border-t-blue-600 mx-auto mb-4"></div>
            <div className="absolute inset-0 rounded-full h-12 w-12 border-4 border-purple-200 border-t-purple-600 animate-spin animation-delay-200"></div>
          </div>
          <p className="text-slate-600 dark:text-slate-400 font-medium">Loading your dashboard...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return null // AuthProvider will handle redirect
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <Sidebar />
      
      <div className="md:ml-64 transition-all duration-300">
        <Header />
        
        <main className="p-6 space-y-8">
          {/* Welcome Section */}
          <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-blue-600 to-purple-600 p-8 text-white shadow-2xl">
            <div className="absolute inset-0 bg-black/10" />
            <div className="relative z-10">
              <h1 className="text-3xl font-bold mb-2">Welcome back, {user.name}! 👋</h1>
              <p className="text-blue-100 text-lg">
                You are logged in as <span className="font-semibold capitalize">{user.role}</span>. 
                Here's your system overview.
              </p>
              </div>
            {/* Decorative elements */}
            <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-16 translate-x-16" />
            <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/5 rounded-full translate-y-12 -translate-x-12" />
        </div>

        {/* Error Message */}
        {statsError && (
            <div className="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl">
              <p className="text-red-700 dark:text-red-400 text-sm">{statsError}</p>
          </div>
        )}

          {/* Stats Overview */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <StatCard
              title="Total Users"
              value={stats?.totalUsers || 0}
              change={stats?.usersChange}
              changeLabel="from last month"
              icon={Users}
              iconColor="text-blue-600"
              trend={stats?.usersChange && stats.usersChange > 0 ? "up" : "down"}
              loading={statsLoading}
            />
            
            <StatCard
              title="Active Machines"
              value={stats?.activeMachines || 0}
              change={stats?.machinesChange}
              changeLabel="from last month"
              icon={Server}
              iconColor="text-green-600"
              trend={stats?.machinesChange && stats.machinesChange > 0 ? "up" : "down"}
              loading={statsLoading}
            />
            
            <StatCard
              title="Knowledge Articles"
              value={stats?.knowledgeArticles || 0}
              change={stats?.articlesChange}
              changeLabel="new this week"
              icon={BookOpen}
              iconColor="text-purple-600"
              trend={stats?.articlesChange && stats.articlesChange > 0 ? "up" : "neutral"}
              loading={statsLoading}
            />
            
            <StatCard
              title="Error Codes"
              value={stats?.errorCodes || 0}
              change={0}
              changeLabel="total available"
              icon={AlertTriangle}
              iconColor="text-orange-600"
              trend="neutral"
              loading={statsLoading}
            />
          </div>

        {/* Quick Actions Grid */}
          <div className="space-y-6">
            <div>
              <h2 className="text-2xl font-bold text-slate-900 dark:text-slate-100 mb-4">
                Quick Actions
              </h2>
              <p className="text-slate-600 dark:text-slate-400 mb-6">
                Manage your system and access key features
              </p>
            </div>
            
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {(user.role === "Admin" || user.role === "Technician") && (
                <ActionCard
                  title="User Management"
                  description="Manage user accounts, roles, and permissions"
                  icon={Users}
                  iconColor="text-blue-600"
                  gradient="from-blue-500 to-purple-600"
                  primaryAction={{
                    label: "View All Users",
                    href: "/users"
                  }}
                  secondaryAction={user.role === "Admin" ? {
                    label: "Add New User",
                    href: "/users"
                  } : undefined}
                />
              )}

              <ActionCard
                title="Machine Management"
                description="Monitor and manage machine inventory"
                icon={Server}
                iconColor="text-green-600"
                gradient="from-green-500 to-emerald-600"
                primaryAction={{
                  label: "View Machines",
                  href: "/machines"
                }}
                secondaryAction={(user.role === "Admin" || user.role === "Technician") ? {
                  label: "Register Machine",
                  href: "/machines"
                } : undefined}
              />

              <ActionCard
                title="Knowledge Base"
                description="Manage documentation and help articles"
                icon={BookOpen}
                iconColor="text-purple-600"
                gradient="from-purple-500 to-pink-600"
                primaryAction={{
                  label: "Browse Articles",
                  href: "/knowledge"
                }}
                secondaryAction={(user.role === "Admin" || user.role === "Technician") ? {
                  label: "Create Article",
                  href: "/knowledge"
                } : undefined}
              />

              <ActionCard
                title="Error Codes"
                description="Manage manufacturing error codes"
                icon={AlertTriangle}
                iconColor="text-orange-600"
                gradient="from-orange-500 to-red-600"
                primaryAction={{
                  label: "View Error Codes",
                  href: "/error-codes"
                }}
                secondaryAction={(user.role === "Admin" || user.role === "Technician") ? {
                  label: "Add Error Code",
                  href: "/error-codes"
                } : undefined}
              />

              <ActionCard
                title="Support Tickets"
                description="Handle customer support requests"
                icon={Ticket}
                iconColor="text-red-600"
                gradient="from-red-500 to-pink-600"
                primaryAction={{
                  label: "View Tickets",
                  href: "/tickets"
                }}
                secondaryAction={(user.role === "Admin" || user.role === "Technician") ? {
                  label: "Create Ticket",
                  href: "/tickets"
                } : undefined}
              />

          {user.role === "Admin" && (
                <>
                  <ActionCard
                    title="Analytics"
                    description="View detailed reports and insights"
                    icon={BarChart3}
                    iconColor="text-indigo-600"
                    gradient="from-indigo-500 to-blue-600"
                    primaryAction={{
                      label: "View Reports",
                      href: "/analytics"
                    }}
                    secondaryAction={{
                      label: "Export Data",
                      href: "/analytics"
                    }}
                  />

                  <ActionCard
                    title="System Settings"
                    description="Configure system preferences"
                    icon={Settings}
                    iconColor="text-slate-600"
                    gradient="from-slate-500 to-gray-600"
                    primaryAction={{
                      label: "System Config",
                      href: "/settings"
                    }}
                    secondaryAction={{
                      label: "Backup Data",
                      href: "/settings"
                    }}
                  />
                </>
              )}
                </div>
        </div>
      </main>
      </div>
    </div>
  )
}
