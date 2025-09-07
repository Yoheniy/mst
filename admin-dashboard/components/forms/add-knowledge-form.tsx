"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { X, BookOpen, FileText, Video, Tag, ExternalLink, Image } from "lucide-react"
import { apiClient } from "@/lib/api-client"
import { KnowledgeBaseContent } from "@/lib/api-client"

interface AddKnowledgeFormProps {
  onClose: () => void
  onSuccess: () => void
}

export function AddKnowledgeForm({ onClose, onSuccess }: AddKnowledgeFormProps) {
  const [formData, setFormData] = useState({
    title: "",
    content_type: "",
    content_text: "",
    external_url: "",
    tags: "",
    applies_to_models: ""
  })
  const [file, setFile] = useState<File | undefined>(undefined)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError("")

    try {
      // Parse tags and models from comma-separated strings
      const tags = formData.tags ? formData.tags.split(',').map(tag => tag.trim()).filter(tag => tag) : []
      const applies_to_models = formData.applies_to_models ? formData.applies_to_models.split(',').map(model => model.trim()).filter(model => model) : []

      // Debug logging
      console.log("Submitting form data:", {
        title: formData.title,
        content_type: formData.content_type,
        hasFile: !!file,
        fileName: file?.name,
        fileSize: file?.size,
        fileType: file?.type
      })

      const response = await apiClient.createKnowledgeBaseItem({
        ...formData,
        tags,
        applies_to_models,
        file
      })

      if (response.error) {
        throw new Error(response.error)
      }

      onSuccess()
      onClose()
    } catch (err) {
      console.error("Form submission error:", err)
      setError(err instanceof Error ? err.message : "Failed to create knowledge base item")
    } finally {
      setIsLoading(false)
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
      case "document":
        return <FileText className="h-4 w-4" />
      case "video":
        return <Video className="h-4 w-4" />
      case "image":
        return <Image className="h-4 w-4" />
      case "guide":
        return <BookOpen className="h-4 w-4" />
      default:
        return <FileText className="h-4 w-4" />
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <Card className="w-full max-w-3xl bg-white dark:bg-slate-800 max-h-[90vh] overflow-y-auto">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle className="text-xl font-bold text-slate-900 dark:text-slate-100">
              Add Knowledge Base Article
            </CardTitle>
            <CardDescription className="text-slate-600 dark:text-slate-400">
              Create a new article for the knowledge base
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
                <Label htmlFor="title" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Title *
                </Label>
                <Input
                  id="title"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="Enter article title"
                  required
                  className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="content_type" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Content Type *
                </Label>
                <select
                  id="content_type"
                  value={formData.content_type}
                  onChange={(e) => setFormData({ ...formData, content_type: e.target.value })}
                  required
                  className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-slate-900 dark:text-slate-100"
                >
                  <option value="">Select content type</option>
                  <option value="manual">Manual</option>
                  <option value="tutorial">Tutorial</option>
                  <option value="troubleshooting">Troubleshooting</option>
                  <option value="faq">FAQ</option>
                  <option value="video">Video</option>
                  <option value="document">Document</option>
                  <option value="image">Image</option>
                  <option value="guide">Guide</option>
                </select>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="content_text" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                Content
              </Label>
              <Textarea
                id="content_text"
                value={formData.content_text}
                onChange={(e) => setFormData({ ...formData, content_text: e.target.value })}
                placeholder="Enter article content..."
                rows={6}
                className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="external_url" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                External URL
              </Label>
              <div className="relative">
                <ExternalLink className="absolute left-3 top-3 h-4 w-4 text-slate-400" />
                <Input
                  id="external_url"
                  type="url"
                  value={formData.external_url}
                  onChange={(e) => setFormData({ ...formData, external_url: e.target.value })}
                  placeholder="https://example.com"
                  className="pl-10 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="tags" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Tags
                </Label>
                <div className="relative">
                  <Tag className="absolute left-3 top-3 h-4 w-4 text-slate-400" />
                  <Input
                    id="tags"
                    value={formData.tags}
                    onChange={(e) => setFormData({ ...formData, tags: e.target.value })}
                    placeholder="tag1, tag2, tag3"
                    className="pl-10 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                  />
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Separate tags with commas
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="applies_to_models" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                  Applies to Models
                </Label>
                <Input
                  id="applies_to_models"
                  value={formData.applies_to_models}
                  onChange={(e) => setFormData({ ...formData, applies_to_models: e.target.value })}
                  placeholder="Model A, Model B, Model C"
                  className="bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                />
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Separate models with commas
                </p>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="file" className="text-sm font-medium text-slate-700 dark:text-slate-300">
                Attachment (optional)
              </Label>
              <input
                id="file"
                type="file"
                onChange={(e) => {
                  const selectedFile = e.target.files?.[0]
                  console.log("File selected:", {
                    name: selectedFile?.name,
                    size: selectedFile?.size,
                    type: selectedFile?.type,
                    lastModified: selectedFile?.lastModified
                  })
                  setFile(selectedFile)
                }}
                className="block w-full text-sm text-slate-700 dark:text-slate-300 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-slate-100 dark:file:bg-slate-700 file:text-slate-700 dark:file:text-slate-200 hover:file:bg-slate-200 dark:hover:file:bg-slate-600"
              />
              {file && (
                <p className="text-xs text-green-600 dark:text-green-400">
                  Selected: {file.name} ({Math.round(file.size / 1024)} KB)
                </p>
              )}
            </div>

            <div className="flex justify-end space-x-3 pt-6">
              <Button type="button" variant="outline" onClick={onClose}>
                Cancel
              </Button>
              <Button 
                type="submit" 
                disabled={isLoading}
                className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white"
              >
                {isLoading ? (
                  <div className="flex items-center space-x-2">
                    <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
                    <span>Creating...</span>
                  </div>
                ) : (
                  <div className="flex items-center space-x-2">
                    <BookOpen className="h-4 w-4" />
                    <span>Add Article</span>
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
