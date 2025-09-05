"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { X, AlertTriangle, AlertCircle, AlertOctagon, Info, Settings } from "lucide-react"
import { apiClient } from "@/lib/api-client"
import { ErrorCode } from "@/lib/api-client"

interface AddErrorCodeFormProps {
  onClose: () => void
  onSuccess: () => void
}

export function AddErrorCodeForm({ onClose, onSuccess }: AddErrorCodeFormProps) {
  const [formData, setFormData] = useState({
    code: "",
    title: "",
    description: "",
    manufacturer_origin: "",
    severity: "",
    suggested_action: ""
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    try {
      const response = await apiClient.createErrorCode(formData)
      
      if (response.error) {
        throw new Error(response.error)
      }
      
      onSuccess()
      onClose()
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create error code")
    } finally {
      setIsLoading(false)
    }
  }

  const getSeverityIcon = (severity: string) => {
    switch (severity.toLowerCase()) {
      case "critical":
        return <AlertOctagon className="h-4 w-4" />
      case "warning":
        return <AlertTriangle className="h-4 w-4" />
      case "minor":
        return <AlertCircle className="h-4 w-4" />
      case "info":
        return <Info className="h-4 w-4" />
      default:
        return <AlertCircle className="h-4 w-4" />
    }
  }

  const getSeverityColor = (severity: string) => {
    switch (severity.toLowerCase()) {
      case "critical":
        return "text-red-600 dark:text-red-400"
      case "warning":
        return "text-yellow-600 dark:text-yellow-400"
      case "minor":
        return "text-blue-600 dark:text-blue-400"
      case "info":
        return "text-green-600 dark:text-green-400"
      default:
        return "text-gray-600 dark:text-gray-400"
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <Card className="w-full max-w-2xl bg-white dark:bg-slate-800">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle className="text-xl font-bold text-slate-900 dark:text-slate-100">
              Add New Error Code
            </CardTitle>
            <CardDescription className="text-slate-600 dark:text-slate-400">
              Create a new error code for troubleshooting
            </CardDescription>
          </div>
          <Button variant="ghost" size="sm" onClick={onClose}>
            <X className="h-4 w-4" />
          </Button>
        </CardHeader>
        
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <Alert className="border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20">
                <AlertDescription className="text-red-700 dark:text-red-400">
                  {error}
                </AlertDescription>
              </Alert>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="code" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Error Code *
                </Label>
                <Input
                  id="code"
                  value={formData.code}
                  onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                  placeholder="e.g., E123, CHL-404"
                  required
                  className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 font-mono"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="title" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Title *
                </Label>
                <Input
                  id="title"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="Error title"
                  required
                  className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="severity" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Severity *
                </Label>
                <select
                  id="severity"
                  value={formData.severity}
                  onChange={(e) => setFormData({ ...formData, severity: e.target.value })}
                  required
                  className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="">Select severity</option>
                  <option value="critical">Critical</option>
                  <option value="warning">Warning</option>
                  <option value="minor">Minor</option>
                </select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="manufacturer_origin" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Manufacturer Origin
                </Label>
                <select
                  id="manufacturer_origin"
                  value={formData.manufacturer_origin}
                  onChange={(e) => setFormData({ ...formData, manufacturer_origin: e.target.value })}
                  className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="">Select manufacturer</option>
                  <option value="machine">Machine</option>
                  <option value="chiller">Chiller</option>
                  <option value="laser_source">Laser Source</option>
                  <option value="drive">Drive</option>
                  <option value="controller">Controller</option>
                  <option value="software">Software</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="description" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                Description
              </Label>
              <Textarea
                id="description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Describe the error condition..."
                rows={4}
                className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="suggested_action" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                Suggested Action
              </Label>
              <Textarea
                id="suggested_action"
                value={formData.suggested_action}
                onChange={(e) => setFormData({ ...formData, suggested_action: e.target.value })}
                placeholder="Provide troubleshooting steps or solution..."
                rows={3}
                className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
              />
            </div>

            {/* Preview */}
            {formData.code && formData.title && formData.severity && (
              <div className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg p-4">
                <h4 className="text-sm font-medium text-slate-700 dark:text-slate-300 mb-3">Preview:</h4>
                <div className="flex items-center space-x-3">
                  <div className={`p-2 rounded-lg ${getSeverityColor(formData.severity)}`}>
                    {getSeverityIcon(formData.severity)}
                  </div>
                  <div>
                    <p className="font-mono font-semibold text-slate-900 dark:text-slate-100">
                      {formData.code}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                      {formData.title}
                    </p>
                  </div>
                </div>
              </div>
            )}

            <div className="flex justify-end space-x-3 pt-6">
              <Button type="button" variant="outline" onClick={onClose}>
                Cancel
              </Button>
              <Button 
                type="submit" 
                disabled={isLoading}
                className="bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700 text-white"
              >
                {isLoading ? (
                  <div className="flex items-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
                    <span>Creating...</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    <AlertTriangle className="h-4 w-4" />
                    <span>Add Error Code</span>
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
