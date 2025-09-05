"use client"

import { useEffect, useState } from "react"
import { useRouter, useParams } from "next/navigation"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { apiClient, ErrorCode } from "@/lib/api-client"
import { API_CONFIG, buildApiUrl } from "@/lib/config"
import { ArrowLeft, Calendar, Edit, Trash2 } from "lucide-react"

export default function ErrorCodeDetailPage() {
  const params = useParams<{ id: string }>()
  const router = useRouter()
  const id = Array.isArray(params?.id) ? params.id[0] : params?.id

  const [item, setItem] = useState<ErrorCode | null>(null)
  const [isLoading, setIsLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)
  const [isEditing, setIsEditing] = useState<boolean>(false)
  const [saving, setSaving] = useState<boolean>(false)
  const [deleting, setDeleting] = useState<boolean>(false)

  const [title, setTitle] = useState("")
  const [code, setCode] = useState("")
  const [description, setDescription] = useState("")
  const [severity, setSeverity] = useState<string | undefined>(undefined)
  const [manufacturer, setManufacturer] = useState<string | undefined>(undefined)
  const [suggestedAction, setSuggestedAction] = useState<string | undefined>(undefined)

  useEffect(() => {
    if (!id) return
    let cancelled = false
    const load = async () => {
      setIsLoading(true)
      setError(null)
      const res = await apiClient.getErrorCode(String(id))
      if (cancelled) return
      if (res.status >= 200 && res.status < 300 && res.data) {
        setItem(res.data)
        setTitle(res.data.title || "")
        setCode(res.data.code || "")
        setDescription(res.data.description || "")
        setSeverity(res.data.severity)
        setManufacturer(res.data.manufacturer_origin)
        setSuggestedAction(res.data.suggested_action)
      } else {
        setError(res.error || "Failed to load error code")
      }
      setIsLoading(false)
    }
    load()
    return () => { cancelled = true }
  }, [id])

  const formatDate = (dateString: string) => new Date(dateString).toLocaleDateString()

  const handleSave = async () => {
    if (!item) return
    setSaving(true)
    setError(null)
    try {
      const endpoint = buildApiUrl(API_CONFIG.ENDPOINTS.ERROR_CODES.UPDATE(String(item.error_code_id)))
      const payload = {
        title,
        code,
        description,
        severity,
        manufacturer_origin: manufacturer,
        suggested_action: suggestedAction,
      }
      const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null
      const resp = await fetch(endpoint, {
        method: "PUT",
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify(payload),
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
    const confirmed = window.confirm("Delete this error code? This cannot be undone.")
    if (!confirmed) return
    setDeleting(true)
    setError(null)
    try {
      const endpoint = buildApiUrl(API_CONFIG.ENDPOINTS.ERROR_CODES.DELETE(String(item.error_code_id)))
      const token = typeof window !== 'undefined' ? localStorage.getItem('access_token') : null
      const resp = await fetch(endpoint, {
        method: "DELETE",
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      })
      if (!resp.ok && resp.status !== 204) {
        const msg = await resp.text()
        throw new Error(msg || "Failed to delete error code")
      }
      router.push("/error-codes")
    } catch (e: any) {
      setError(e?.message || "Failed to delete error code")
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
                <p className="text-slate-600 dark:text-slate-400">Loading error code...</p>
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
            <Button variant="ghost" onClick={() => router.push("/error-codes")}>
              <ArrowLeft className="h-4 w-4 mr-2" /> Back to Error Codes
            </Button>
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <p className="text-red-600 dark:text-red-400">{error || "Error code not found."}</p>
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
              <Link href="/error-codes">
                <ArrowLeft className="h-4 w-4 mr-2" /> Back to Error Codes
              </Link>
            </Button>
            <div className="flex items-center gap-2">
              {!isEditing ? (
                <>
                  <Button variant="outline" onClick={() => setIsEditing(true)} disabled={deleting}>
                    <Edit className="h-4 w-4 mr-2" /> Edit
                  </Button>
                  <Button variant="destructive" onClick={handleDelete} disabled={deleting}>
                    <Trash2 className="h-4 w-4 mr-2" /> {deleting ? "Deleting..." : "Delete"}
                  </Button>
                </>
              ) : (
                <>
                  <Button onClick={handleSave} disabled={saving}>
                    {saving ? "Saving..." : "Save"}
                  </Button>
                  <Button variant="outline" onClick={() => { setIsEditing(false); setTitle(item.title); setCode(item.code); setDescription(item.description || ""); setSeverity(item.severity); setManufacturer(item.manufacturer_origin); setSuggestedAction(item.suggested_action) }} disabled={saving}>
                    Cancel
                  </Button>
                </>
              )}
            </div>
          </div>

          <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
            <CardHeader>
              <div className="flex items-start justify-between gap-4">
                <div className="w-full space-y-3">
                  {!isEditing ? (
                    <CardTitle className="text-2xl text-slate-900 dark:text-slate-100">
                      {item.code}: {item.title}
                    </CardTitle>
                  ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      <input className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100" value={code} onChange={(e) => setCode(e.target.value)} placeholder="Code" />
                      <input className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Title" />
                    </div>
                  )}
                  <div className="flex flex-wrap items-center gap-2 text-slate-600 dark:text-slate-400">
                    <span className="inline-flex items-center gap-2">
                      <Badge>{item.severity || 'unknown'}</Badge>
                      <Badge variant="outline">{item.manufacturer_origin || 'n/a'}</Badge>
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
              {!isEditing ? (
                <>
                  {item.description && (
                    <div className="prose prose-slate dark:prose-invert max-w-none whitespace-pre-wrap">
                      {item.description}
                    </div>
                  )}
                  {item.suggested_action && (
                    <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-3">
                      <p className="text-sm font-medium text-blue-800 dark:text-blue-200 mb-1">Suggested Action</p>
                      <p className="text-sm text-blue-700 dark:text-blue-300 whitespace-pre-wrap">{item.suggested_action}</p>
                    </div>
                  )}
                </>
              ) : (
                <>
                  <textarea className="w-full min-h-[120px] rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100" value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Description" />
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                    <select className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100" value={severity || ''} onChange={(e) => setSeverity(e.target.value || undefined)}>
                      <option value="">Severity</option>
                      <option value="critical">critical</option>
                      <option value="warning">warning</option>
                      <option value="minor">minor</option>
                      <option value="info">info</option>
                    </select>
                    <input className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100" value={manufacturer || ''} onChange={(e) => setManufacturer(e.target.value || undefined)} placeholder="Manufacturer" />
                    <textarea className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100 min-h-[80px]" value={suggestedAction || ''} onChange={(e) => setSuggestedAction(e.target.value || undefined)} placeholder="Suggested action" />
                  </div>
                </>
              )}
            </CardContent>
          </Card>
        </main>
      </div>
    </div>
  )
}


