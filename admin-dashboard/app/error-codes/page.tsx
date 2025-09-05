"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { 
  AlertTriangle, 
  Search, 
  Plus, 
  Filter,
  MoreHorizontal,
  Edit,
  Trash2,
  AlertCircle,
  AlertOctagon,
  Info,
  Calendar,
  Settings
} from "lucide-react"
import { useErrorCodes } from "@/hooks/use-dashboard-data"
import { ErrorCode } from "@/lib/api-client"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { AddErrorCodeForm } from "@/components/forms/add-error-code-form"
import Link from "next/link"

export default function ErrorCodesPage() {
  const { errorCodes, isLoading, error } = useErrorCodes()
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedSeverity, setSelectedSeverity] = useState<string>("all")
  const [selectedManufacturer, setSelectedManufacturer] = useState<string>("all")
  const [showAddForm, setShowAddForm] = useState(false)

  const filteredErrorCodes = errorCodes.filter(errorCode => {
    const matchesSearch = errorCode.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         errorCode.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         errorCode.description?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesSeverity = selectedSeverity === "all" || errorCode.severity === selectedSeverity
    const matchesManufacturer = selectedManufacturer === "all" || errorCode.manufacturer_origin === selectedManufacturer
    return matchesSearch && matchesSeverity && matchesManufacturer
  })

  const getSeverityColor = (severity?: string) => {
    switch (severity?.toLowerCase()) {
      case "critical":
        return "bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400"
      case "warning":
        return "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400"
      case "minor":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400"
      case "info":
        return "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
    }
  }

  const getSeverityIcon = (severity?: string) => {
    switch (severity?.toLowerCase()) {
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

  const getManufacturerColor = (manufacturer?: string) => {
    switch (manufacturer?.toLowerCase()) {
      case "machine":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400"
      case "chiller":
        return "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400"
      case "laser source":
        return "bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400"
      case "controller":
        return "bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-400"
      case "software":
        return "bg-indigo-100 text-indigo-800 dark:bg-indigo-900/20 dark:text-indigo-400"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString()
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
                <p className="text-slate-600 dark:text-slate-400">Loading error codes...</p>
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
              <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">Error Codes</h1>
              <p className="text-slate-600 dark:text-slate-400 mt-2">
                Manage manufacturing error codes and troubleshooting guides
              </p>
            </div>
            <Button 
              onClick={() => setShowAddForm(true)}
              className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add Error Code
            </Button>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg">
                    <AlertTriangle className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {errorCodes.length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Total Error Codes</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-red-100 dark:bg-red-900/50 rounded-lg">
                    <AlertOctagon className="h-6 w-6 text-red-600 dark:text-red-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {errorCodes.filter(e => e.severity === 'critical').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Critical Errors</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-yellow-100 dark:bg-yellow-900/50 rounded-lg">
                    <AlertTriangle className="h-6 w-6 text-yellow-600 dark:text-yellow-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {errorCodes.filter(e => e.severity === 'warning').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Warnings</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-green-100 dark:bg-green-900/50 rounded-lg">
                    <Settings className="h-6 w-6 text-green-600 dark:text-green-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {new Set(errorCodes.map(e => e.manufacturer_origin)).size}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Manufacturers</p>
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
                    placeholder="Search error codes..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                  />
                </div>
                <select
                  value={selectedSeverity}
                  onChange={(e) => setSelectedSeverity(e.target.value)}
                  className="px-4 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="all">All Severities</option>
                  {Array.from(new Set(errorCodes.map(e => e.severity))).map(severity => (
                    <option key={severity} value={severity}>{severity}</option>
                  ))}
                </select>
                <select
                  value={selectedManufacturer}
                  onChange={(e) => setSelectedManufacturer(e.target.value)}
                  className="px-4 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="all">All Manufacturers</option>
                  {Array.from(new Set(errorCodes.map(e => e.manufacturer_origin))).map(manufacturer => (
                    <option key={manufacturer} value={manufacturer}>{manufacturer}</option>
                  ))}
                </select>
              </div>
            </CardContent>
          </Card>

          {/* Error Codes Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredErrorCodes.map((errorCode) => (
              <Link key={errorCode.error_code_id} href={`/error-codes/${errorCode.error_code_id}`} className="group">
              <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 hover:shadow-lg transition-all duration-200 group-hover:translate-y-[-2px]">
                <CardHeader className="pb-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="p-2 bg-gradient-to-br from-red-100 to-orange-100 dark:from-red-900/50 dark:to-orange-900/50 rounded-lg">
                        {getSeverityIcon(errorCode.severity)}
                      </div>
                      <div>
                        <CardTitle className="text-lg text-slate-900 dark:text-slate-100 font-mono">
                          {errorCode.code}
                        </CardTitle>
                        <CardDescription className="text-slate-600 dark:text-slate-400">
                          {errorCode.title}
                        </CardDescription>
                      </div>
                    </div>
                    <Badge className={getSeverityColor(errorCode.severity)}>
                      {errorCode.severity}
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  {errorCode.description && (
                    <p className="text-sm text-slate-600 dark:text-slate-400 line-clamp-3">
                      {errorCode.description}
                    </p>
                  )}
                  
                  <div className="space-y-2">
                    {errorCode.manufacturer_origin && (
                      <Badge className={getManufacturerColor(errorCode.manufacturer_origin)}>
                        {errorCode.manufacturer_origin}
                      </Badge>
                    )}
                    
                    {errorCode.suggested_action && (
                      <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-3">
                        <p className="text-sm font-medium text-blue-800 dark:text-blue-200 mb-1">
                          Suggested Action:
                        </p>
                        <p className="text-sm text-blue-700 dark:text-blue-300">
                          {errorCode.suggested_action}
                        </p>
                      </div>
                    )}
                    
                    <div className="flex items-center space-x-2 text-sm">
                      <Calendar className="h-4 w-4 text-slate-400" />
                      <span className="text-slate-600 dark:text-slate-400">Created:</span>
                      <span className="text-slate-900 dark:text-slate-100">
                        {formatDate(errorCode.created_at)}
                      </span>
                    </div>
                  </div>
                  
                  <div className="flex items-center justify-between pt-4 border-t border-slate-200 dark:border-slate-700">
                    <div className="flex items-center space-x-2">
                      <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                        <Edit className="h-4 w-4" />
                      </Button>
                    </div>
                    <Button variant="ghost" size="sm" className="h-8 w-8 p-0 text-red-600 hover:text-red-700">
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
              </Link>
            ))}
          </div>

          {filteredErrorCodes.length === 0 && (
            <div className="text-center py-12">
              <AlertTriangle className="h-12 w-12 text-slate-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100 mb-2">
                No error codes found
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Try adjusting your search or filter criteria.
              </p>
            </div>
          )}
        </main>
      </div>

      {/* Add Error Code Form Modal */}
      {showAddForm && (
        <AddErrorCodeForm
          onClose={() => setShowAddForm(false)}
          onSuccess={() => {
            // Refresh the error codes list
            window.location.reload()
          }}
        />
      )}
    </div>
  )
}
