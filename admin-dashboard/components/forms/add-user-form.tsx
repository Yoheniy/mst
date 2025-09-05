"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { X, UserPlus } from "lucide-react"
import { apiClient, User } from "@/lib/api-client"

interface AddUserFormProps {
  onClose: () => void
  onSuccess: (user: User) => void
}

export function AddUserForm({ onClose, onSuccess }: AddUserFormProps) {
  const [formData, setFormData] = useState({
    email: "",
    full_name: "",
    phone_number: "",
    company_name: "",
    role: "customer",
    employee_id: ""
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    try {
      const payload: any = {
        email: formData.email,
        full_name: formData.full_name,
        phone_number: formData.phone_number || undefined,
        company_name: formData.company_name || undefined,
        role: formData.role,
        employee_id: formData.role === "technician" ? formData.employee_id : undefined,
      }
      const res = await apiClient.createUser(payload)
      if (res.error) {
        throw new Error(res.error)
      }
      onSuccess(res.data as User)
      onClose()
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create user")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <Card className="w-full max-w-xl bg-white dark:bg-slate-800">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle className="text-xl font-bold text-slate-900 dark:text-slate-100">
              Add New User
            </CardTitle>
            <CardDescription className="text-slate-600 dark:text-slate-400">
              An email with a generated password will be sent to the user
            </CardDescription>
          </div>
          <Button variant="ghost" size="sm" onClick={onClose}>
            <X className="h-4 w-4" />
          </Button>
        </CardHeader>
        <CardContent>
          <form onSubmit={submit} className="space-y-5">
            {error && (
              <Alert className="border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20">
                <AlertDescription className="text-red-700 dark:text-red-400">
                  {error}
                </AlertDescription>
              </Alert>
            )}

            <div className="space-y-2">
              <Label htmlFor="email">Email *</Label>
              <Input id="email" type="email" required value={formData.email} onChange={(e)=>setFormData({...formData,email:e.target.value})} />
            </div>

            <div className="space-y-2">
              <Label htmlFor="full_name">Full Name *</Label>
              <Input id="full_name" required value={formData.full_name} onChange={(e)=>setFormData({...formData,full_name:e.target.value})} />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="phone_number">Phone</Label>
                <Input id="phone_number" value={formData.phone_number} onChange={(e)=>setFormData({...formData,phone_number:e.target.value})} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="company_name">Company</Label>
                <Input id="company_name" value={formData.company_name} onChange={(e)=>setFormData({...formData,company_name:e.target.value})} />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="role">Role *</Label>
                <select id="role" value={formData.role} onChange={(e)=>setFormData({...formData,role:e.target.value})} className="w-full px-3 py-2 rounded-lg border bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700">
                  <option value="customer">Customer</option>
                  <option value="technician">Technician</option>
                  <option value="sales_agent">Sales Agent</option>
                </select>
              </div>
              {formData.role === "technician" && (
                <div className="space-y-2">
                  <Label htmlFor="employee_id">Employee ID *</Label>
                  <Input id="employee_id" required value={formData.employee_id} onChange={(e)=>setFormData({...formData,employee_id:e.target.value})} />
                </div>
              )}
            </div>

            <div className="flex justify-end space-x-3 pt-2">
              <Button type="button" variant="outline" onClick={onClose}>Cancel</Button>
              <Button type="submit" disabled={isLoading} className="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
                {isLoading ? (
                  <div className="flex items-center space-x-2">
                    <div className="animate-spin h-4 w-4 rounded-full border-2 border-white border-t-transparent" />
                    <span>Creating...</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    <UserPlus className="h-4 w-4" />
                    <span>Add User</span>
                  </div>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
