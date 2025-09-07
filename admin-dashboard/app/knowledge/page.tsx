"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  BookOpen, 
  Search, 
  Plus, 
  Filter,
  MoreHorizontal,
  Edit,
  Trash2,
  ExternalLink,
  Tag,
  Calendar,
  FileText,
  Video,
  Image
} from "lucide-react"
import Link from "next/link"
import { useKnowledgeBase } from "@/hooks/use-dashboard-data"
import { KnowledgeBaseContent } from "@/lib/api-client"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { AddKnowledgeForm } from "@/components/forms/add-knowledge-form"

export default function KnowledgeBasePage() {
  const { knowledgeBase, isLoading, error } = useKnowledgeBase()
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedType, setSelectedType] = useState<string>("all")
  const [showAddForm, setShowAddForm] = useState(false)

  const filteredContent = knowledgeBase.filter(content => {
    const matchesSearch = content.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         content.content_text?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesType = selectedType === "all" || content.content_type === selectedType
    return matchesSearch && matchesType
  })

  const getTypeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case "manual":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400"
      case "tutorial":
        return "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400"
      case "troubleshooting":
        return "bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400"
      case "faq":
        return "bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400"
      case "video":
        return "bg-orange-100 text-orange-800 dark:bg-orange-900/20 dark:text-orange-400"
      case "document":
        return "bg-amber-100 text-amber-800 dark:bg-amber-900/20 dark:text-amber-400"
      case "image":
        return "bg-pink-100 text-pink-800 dark:bg-pink-900/20 dark:text-pink-400"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type.toLowerCase()) {
      case "manual":
        return <FileText className="h-4 w-4" />
      case "tutorial":
        return <BookOpen className="h-4 w-4" />
      case "troubleshooting":
        return <BookOpen className="h-4 w-4" />
      case "faq":
        return <BookOpen className="h-4 w-4" />
      case "video":
        return <Video className="h-4 w-4" />
      case "document":
        return <FileText className="h-4 w-4" />
      case "image":
        return <Image className="h-4 w-4" />
      default:
        return <FileText className="h-4 w-4" />
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
                <p className="text-slate-600 dark:text-slate-400">Loading knowledge base...</p>
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
              <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">Knowledge Base</h1>
              <p className="text-slate-600 dark:text-slate-400 mt-2">
                Manage documentation and help articles
              </p>
            </div>
            <Button 
              onClick={() => setShowAddForm(true)}
              className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white"
            >
              <Plus className="h-4 w-4 mr-2" />
              Add Article
              </Button>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-6">
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg">
                    <BookOpen className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Total Articles</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-green-100 dark:bg-green-900/50 rounded-lg">
                    <FileText className="h-6 w-6 text-green-600 dark:text-green-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.filter(k => k.content_type === 'manual').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Manuals</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-purple-100 dark:bg-purple-900/50 rounded-lg">
                    <BookOpen className="h-6 w-6 text-purple-600 dark:text-purple-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.filter(k => k.content_type === 'tutorial').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Tutorials</p>
                </div>
                </div>
            </CardContent>
          </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-orange-100 dark:bg-orange-900/50 rounded-lg">
                    <Video className="h-6 w-6 text-orange-600 dark:text-orange-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.filter(k => k.content_type === 'video').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Videos</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-amber-100 dark:bg-amber-900/50 rounded-lg">
                    <FileText className="h-6 w-6 text-amber-600 dark:text-amber-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.filter(k => k.content_type === 'document').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Documents</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-pink-100 dark:bg-pink-900/50 rounded-lg">
                    <Image className="h-6 w-6 text-pink-600 dark:text-pink-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {knowledgeBase.filter(k => k.content_type === 'image').length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Images</p>
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
                    placeholder="Search articles..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                  />
                </div>
                <select
                  value={selectedType}
                  onChange={(e) => setSelectedType(e.target.value)}
                  className="px-4 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="all">All Types</option>
                  {Array.from(new Set(knowledgeBase.map(k => k.content_type))).map(type => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
            </div>
          </CardContent>
        </Card>

          {/* Articles Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredContent.map((content) => (
              <Link key={content.kb_id} href={`/knowledge/${content.kb_id}`} className="group">
                <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 hover:shadow-lg transition-all duration-200 group-hover:translate-y-[-2px]">
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        <div className="p-2 bg-gradient-to-br from-blue-100 to-purple-100 dark:from-blue-900/50 dark:to-purple-900/50 rounded-lg">
                          {getTypeIcon(content.content_type)}
                        </div>
                        <div>
                          <CardTitle className="text-lg text-slate-900 dark:text-slate-100 line-clamp-2">
                            {content.title}
            </CardTitle>
                          <CardDescription className="text-slate-600 dark:text-slate-400">
                            {content.content_type}
                          </CardDescription>
                        </div>
                      </div>
                      <Badge className={getTypeColor(content.content_type)}>
                        {content.content_type}
                      </Badge>
                    </div>
          </CardHeader>
                  <CardContent className="space-y-4">
                    {content.content_text && (
                      <p className="text-sm text-slate-600 dark:text-slate-400 line-clamp-3">
                        {content.content_text}
                      </p>
                    )}
                    
                    <div className="space-y-2">
                      {content.tags && content.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {content.tags.slice(0, 3).map((tag, index) => (
                            <Badge key={index} variant="outline" className="text-xs">
                            {tag}
                          </Badge>
                        ))}
                          {content.tags.length > 3 && (
                          <Badge variant="outline" className="text-xs">
                              +{content.tags.length - 3} more
                          </Badge>
                        )}
                        </div>
                      )}
                      
                      <div className="flex items-center space-x-2 text-sm">
                        <Calendar className="h-4 w-4 text-slate-400" />
                        <span className="text-slate-600 dark:text-slate-400">Created:</span>
                        <span className="text-slate-900 dark:text-slate-100">
                          {formatDate(content.created_at)}
                        </span>
                      </div>
                    </div>
          </CardContent>
        </Card>
              </Link>
                  ))}
                </div>

          {filteredContent.length === 0 && (
            <div className="text-center py-12">
              <BookOpen className="h-12 w-12 text-slate-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100 mb-2">
                No articles found
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Try adjusting your search or filter criteria.
              </p>
            </div>
          )}
        </main>
              </div>

      {/* Add Knowledge Base Form Modal */}
      {showAddForm && (
        <AddKnowledgeForm
          onClose={() => setShowAddForm(false)}
          onSuccess={() => {
            // Refresh the knowledge base list
            window.location.reload()
          }}
        />
      )}
    </div>
  )
}
