"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { useParams } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { apiClient, KnowledgeBaseContent } from "@/lib/api-client"
import { API_CONFIG, buildApiUrl } from "@/lib/config"
import { Calendar, ArrowLeft, ExternalLink, FileText, Video, Tag } from "lucide-react"

export default function KnowledgeDetailPage() {
  const params = useParams<{ id: string }>()
  const router = useRouter()
  const id = Array.isArray(params?.id) ? params.id[0] : params?.id

  const [item, setItem] = useState<KnowledgeBaseContent | null>(null)
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)
  const [isEditing, setIsEditing] = useState<boolean>(false)
  const [saving, setSaving] = useState<boolean>(false)
  const [deleting, setDeleting] = useState<boolean>(false)
  const [editedTitle, setEditedTitle] = useState<string>("")
  const [editedContent, setEditedContent] = useState<string>("")

  useEffect(() => {
    if (!id) return
    let cancelled = false
    const load = async () => {
      setIsLoading(true)
      setError(null)
      const res = await apiClient.getKnowledgeBaseItem(String(id))
      if (cancelled) return
      if (res.status >= 200 && res.status < 300 && res.data) {
        setItem(res.data)
        setEditedTitle(res.data.title)
        setEditedContent(res.data.content_text || "")
      } else {
        setError(res.error || "Failed to load article")
      }
      setIsLoading(false)
    }
    load()
    return () => { cancelled = true }
  }, [id])

  const formatDate = (dateString: string) => new Date(dateString).toLocaleDateString()

  const TypeIcon = ({ type }: { type?: string }) => {
    if (!type) return <FileText className="h-4 w-4" />
    switch (type.toLowerCase()) {
      case "video":
        return <Video className="h-4 w-4" />
      default:
        return <FileText className="h-4 w-4" />
    }
  }

  const handleSave = async () => {
    if (!item) return
    setSaving(true)
    setError(null)
    try {
      const endpoint = buildApiUrl(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.UPDATE(String(item.kb_id)))
      const form = new FormData()
      form.append("title", editedTitle)
      form.append("content_text", editedContent)
      const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null
      const resp = await fetch(endpoint, {
        method: "PUT",
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: form,
      })
      if (!resp.ok) {
        const msg = await resp.text()
        throw new Error(msg || "Failed to save changes")
      }
      const updated = await resp.json()
      setItem(updated)
      setIsEditing(false)
    } catch (e: any) {
      setError(e?.message || "Failed to save changes")
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async () => {
    if (!item) return
    const confirmed = window.confirm("Delete this article? This cannot be undone.")
    if (!confirmed) return
    setDeleting(true)
    setError(null)
    try {
      const endpoint = buildApiUrl(API_CONFIG.ENDPOINTS.KNOWLEDGE_BASE.DELETE(String(item.kb_id)))
      const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null
      const resp = await fetch(endpoint, {
        method: "DELETE",
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      })
      if (!resp.ok && resp.status !== 204) {
        const msg = await resp.text()
        throw new Error(msg || "Failed to delete article")
      }
      router.push("/knowledge")
    } catch (e: any) {
      setError(e?.message || "Failed to delete article")
    } finally {
      setDeleting(false)
    }
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
                <p className="text-slate-600 dark:text-slate-400">Loading article...</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  if (error || !item) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <Sidebar />
        <div className="md:ml-64 transition-all duration-300">
          <Header />
          <main className="p-6 space-y-4">
            <Button variant="ghost" onClick={() => router.push("/knowledge")}> 
              <ArrowLeft className="h-4 w-4 mr-2" /> Back to Knowledge
            </Button>
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <p className="text-red-600 dark:text-red-400">{error || "Article not found."}</p>
              </CardContent>
            </Card>
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
          <div className="flex items-center justify-between">
            <Button variant="ghost" asChild>
              <Link href="/knowledge">
                <ArrowLeft className="h-4 w-4 mr-2" /> Back to Knowledge
              </Link>
            </Button>
            <div className="flex items-center gap-2">
              {!isEditing ? (
                <>
                  <Button variant="outline" onClick={() => setIsEditing(true)} disabled={deleting}>
                    Edit
                  </Button>
                  <Button variant="destructive" onClick={handleDelete} disabled={deleting}>
                    {deleting ? "Deleting..." : "Delete"}
                  </Button>
                </>
              ) : (
                <>
                  <Button onClick={handleSave} disabled={saving}>
                    {saving ? "Saving..." : "Save"}
                  </Button>
                  <Button variant="outline" onClick={() => { setIsEditing(false); setEditedTitle(item.title); setEditedContent(item.content_text || "") }} disabled={saving}>
                    Cancel
                  </Button>
                </>
              )}
            </div>
          </div>

          <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
            <CardHeader>
              <div className="flex items-start justify-between gap-4">
                <div>
                  {!isEditing ? (
                    <CardTitle className="text-2xl text-slate-900 dark:text-slate-100">
                      {item.title}
                    </CardTitle>
                  ) : (
                    <input
                      className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      value={editedTitle}
                      onChange={(e) => setEditedTitle(e.target.value)}
                      placeholder="Title"
                    />
                  )}
                  <div className="mt-2 flex flex-wrap items-center gap-2 text-slate-600 dark:text-slate-400">
                    <span className="inline-flex items-center gap-1">
                      <TypeIcon type={item.content_type as any} />
                      {item.content_type}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      Created {formatDate(item.created_at)}
                    </span>
                  </div>
                </div>
              </div>
            </CardHeader>

            <CardContent className="space-y-6">
              {/* Tags */}
              {item.tags && item.tags.length > 0 && (
                <div className="flex flex-wrap gap-2">
                  {item.tags.map((tag, idx) => (
                    <Badge key={idx} variant="outline" className="inline-flex items-center gap-1">
                      <Tag className="h-3 w-3" /> {tag}
                    </Badge>
                  ))}
                </div>
              )}

              {/* Main content */}
              {!isEditing ? (
                item.content_text ? (
                  <div className="prose prose-slate dark:prose-invert max-w-none whitespace-pre-wrap">
                    {item.content_text}
                  </div>
                ) : null
              ) : (
                <textarea
                  className="w-full min-h-[160px] rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  value={editedContent}
                  onChange={(e) => setEditedContent(e.target.value)}
                  placeholder="Write content..."
                />
              )}

              {/* Video or external resource */}
              {(() => {
                const isVideo = (item.content_type || "").toLowerCase() === "video"
                if (isVideo) {
                  return item.external_url ? (
                    <div className="w-full">
                      <div className="relative w-full max-w-2xl md:max-w-4xl mx-auto aspect-video rounded-lg overflow-hidden border border-slate-200 dark:border-slate-700 bg-black">
                        <video
                          className="absolute inset-0 w-full h-full object-contain"
                          src={item.external_url}
                          controls
                          playsInline
                        />
                      </div>
                    </div>
                  ) : (
                    <div className="text-sm text-slate-600 dark:text-slate-400">
                      Video not available.
                    </div>
                  )
                }
                return item.external_url ? (
                  <div>
                    <Button asChild variant="secondary">
                      <a href={item.external_url} target="_blank" rel="noopener noreferrer">
                        <ExternalLink className="h-4 w-4 mr-2" /> Open external resource
                      </a>
                    </Button>
                  </div>
                ) : null
              })()}
            </CardContent>
          </Card>
        </main>
      </div>
    </div>
  )
}


