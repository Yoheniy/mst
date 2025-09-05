"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Users, 
  Search, 
  Plus, 
  Filter,
  MoreHorizontal,
  Edit,
  Trash2,
  UserPlus
} from "lucide-react"
import { useUsers } from "@/hooks/use-dashboard-data"
import { User } from "@/lib/api-client"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { AddUserForm } from "@/components/forms/add-user-form"
import { apiClient, User as UserType } from "@/lib/api-client"

export default function UsersPage() {
  const { users, isLoading, error } = useUsers()
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedRole, setSelectedRole] = useState<string>("all")
  const [showAddForm, setShowAddForm] = useState(false)
  const [opError, setOpError] = useState("")
  const [editingUserId, setEditingUserId] = useState<number | null>(null)
  const [edited, setEdited] = useState<Partial<UserType>>({})

  const refresh = () => window.location.reload()

  const handleDelete = async (userId: number) => {
    setOpError("")
    const confirmed = window.confirm("Are you sure you want to delete this user? This action cannot be undone.")
    if (!confirmed) return
    const res = await apiClient.deleteUser(String(userId))
    if (res.error) {
      setOpError(res.error)
      return
    }
    refresh()
  }

  const beginEdit = (user: UserType) => {
    setEditingUserId(user.user_id)
    setEdited({
      full_name: user.full_name,
      email: user.email,
      role: user.role,
      company_name: user.company_name,
      phone_number: user.phone_number,
      employee_id: user.employee_id,
    })
  }

  const cancelEdit = () => {
    setEditingUserId(null)
    setEdited({})
  }

  const saveEdit = async (userId: number) => {
    setOpError("")
    const res = await apiClient.updateUser(String(userId), edited)
    if (res.error) {
      setOpError(res.error)
      return
    }
    cancelEdit()
    refresh()
  }

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.company_name?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesRole = selectedRole === "all" || user.role === selectedRole
    return matchesSearch && matchesRole
  })

  const getRoleColor = (role: string) => {
    switch (role) {
      case "admin":
        return "bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400"
      case "technician":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400"
      case "sales_agent":
        return "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400"
      case "customer":
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
    }
  }

  const getRoleLabel = (role: string) => {
    return role.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ')
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <Sidebar />
        <div className="md:ml-64 transition-all duration-300">
          <Header />
          <main className="p-6">
            <div className="flex items-center justify-center h-64">
              <div className="text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 border-t-transparent mx-auto mb-4"></div>
                <p className="text-slate-600 dark:text-slate-400">Loading users...</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <Sidebar />
        <div className="md:ml-64 transition-all duration-300">
          <Header />
          <main className="p-6">
            <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
              <p className="text-red-700 dark:text-red-400">{error}</p>
            </div>
          </main>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <Sidebar />
      
      <div className="md:ml-64 transition-all duration-300">
        <Header />
        
        <main className="p-6 space-y-6">
      {/* Header */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
            <div>
              <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">Users</h1>
              <p className="text-slate-600 dark:text-slate-400 mt-2">
                Manage user accounts and permissions
              </p>
            </div>
            <Button className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white" onClick={()=>setShowAddForm(true)}>
              <UserPlus className="h-4 w-4 mr-2" />
              Add User
              </Button>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
          <div className="flex items-center space-x-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg">
                    <Users className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {users.length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Total Users</p>
          </div>
        </div>
            </CardContent>
          </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-red-100 dark:bg-red-900/50 rounded-lg">
                    <Users className="h-6 w-6 text-red-600 dark:text-red-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {users.filter(u => u.role === 'admin').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Admins</p>
                  </div>
              </div>
            </CardContent>
          </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg">
                    <Users className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {users.filter(u => u.role === 'technician').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Technicians</p>
                  </div>
                </div>
            </CardContent>
          </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-green-100 dark:bg-green-900/50 rounded-lg">
                    <Users className="h-6 w-6 text-green-600 dark:text-green-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {users.filter(u => u.role === 'customer').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Customers</p>
                  </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Filters and Search */}
          <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
            <CardContent className="p-6">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="relative flex-1">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-slate-400" />
                  <Input
                    placeholder="Search users..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                  />
                </div>
                <select
                  value={selectedRole}
                  onChange={(e) => setSelectedRole(e.target.value)}
                  className="px-4 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="all">All Roles</option>
                  <option value="admin">Admin</option>
                  <option value="technician">Technician</option>
                  <option value="sales_agent">Sales Agent</option>
                  <option value="customer">Customer</option>
                </select>
            </div>
          </CardContent>
        </Card>

          {opError && (
            <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4">
              <p className="text-red-700 dark:text-red-400">{opError}</p>
            </div>
          )}

          {/* Users List */}
          {/* make it two column */}
          <div className="grid gap-4">
                {filteredUsers.map((user) => (
              <Card key={user.user_id} className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 hover:shadow-lg transition-all duration-200">
                <CardContent className="p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="h-12 w-12 bg-gradient-to-br from-blue-600 to-purple-600 rounded-full flex items-center justify-center">
                        <span className="text-white font-semibold text-lg">
                          {user.full_name.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div>
                        {editingUserId === user.user_id ? (
                          <div className="space-y-2">
                            <input
                              className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                              value={edited.full_name || ''}
                              onChange={(e)=>setEdited(v=>({...v, full_name: e.target.value}))}
                              placeholder="Full name"
                            />
                            <input
                              className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                              value={edited.email || ''}
                              onChange={(e)=>setEdited(v=>({...v, email: e.target.value}))}
                              placeholder="Email"
                            />
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
                              <select
                                className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                                value={edited.role || ''}
                                onChange={(e)=>setEdited(v=>({...v, role: e.target.value}))}
                              >
                                <option value="admin">Admin</option>
                                <option value="technician">Technician</option>
                                <option value="sales_agent">Sales Agent</option>
                                <option value="customer">Customer</option>
                              </select>
                              <input
                                className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                                value={edited.company_name || ''}
                                onChange={(e)=>setEdited(v=>({...v, company_name: e.target.value}))}
                                placeholder="Company"
                              />
                              <input
                                className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                                value={edited.phone_number || ''}
                                onChange={(e)=>setEdited(v=>({...v, phone_number: e.target.value}))}
                                placeholder="Phone"
                              />
                            </div>
                            <input
                              className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                              value={edited.employee_id || ''}
                              onChange={(e)=>setEdited(v=>({...v, employee_id: e.target.value}))}
                              placeholder="Employee ID"
                            />
                          </div>
                        ) : (
                          <>
                            <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">
                              {user.full_name}
                            </h3>
                            <p className="text-slate-600 dark:text-slate-400">{user.email}</p>
                            {user.company_name && (
                              <p className="text-sm text-slate-500 dark:text-slate-500">{user.company_name}</p>
                            )}
                          </>
                        )}
                      </div>
                    </div>
                    <div className="flex items-center space-x-4">
                      <Badge className={getRoleColor(user.role)}>
                        {getRoleLabel(user.role)}
                      </Badge>
                      <div className="flex items-center space-x-2">
                        {editingUserId === user.user_id ? (
                          <>
                            <Button variant="ghost" size="sm" className="h-8 px-2" onClick={()=>saveEdit(user.user_id)}>Save</Button>
                            <Button variant="ghost" size="sm" className="h-8 px-2" onClick={cancelEdit}>Cancel</Button>
                          </>
                        ) : (
                          <>
                            <Button variant="ghost" size="sm" className="h-8 w-8 p-0" onClick={()=>beginEdit(user)}>
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button variant="ghost" size="sm" className="h-8 w-8 p-0 text-red-600 hover:text-red-700" onClick={()=>handleDelete(user.user_id)}>
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </>
                        )}
                      </div>
                    </div>
                  </div>
          </CardContent>
        </Card>
            ))}
              </div>

          {filteredUsers.length === 0 && (
            <div className="text-center py-12">
              <Users className="h-12 w-12 text-slate-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100 mb-2">
                No users found
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Try adjusting your search or filter criteria.
              </p>
            </div>
          )}
      </main>
      </div>
      {showAddForm && (
        <AddUserForm onClose={()=>setShowAddForm(false)} onSuccess={()=>refresh()} />
      )}
    </div>
  )
}
