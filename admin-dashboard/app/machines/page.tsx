"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Server, 
  Search, 
  Plus, 
  Filter,
  MoreHorizontal,
  Edit,
  Trash2,
  Settings,
  Calendar,
  MapPin
} from "lucide-react"
import { useMachines } from "@/hooks/use-dashboard-data"
import { Machine } from "@/lib/api-client"
import { Sidebar } from "@/components/sidebar"
import { Header } from "@/components/header"
import { AddMachineForm } from "@/components/forms/add-machine-form"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { apiClient, MachineModelDto, Machine as MachineType } from "@/lib/api-client"
import { useEffect } from "react"

export default function MachinesPage() {
  const { machines, isLoading, error } = useMachines()
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedType, setSelectedType] = useState<string>("all")
  const [showAddForm, setShowAddForm] = useState(false)
  const [activeTab, setActiveTab] = useState("current")
  const [notOwned, setNotOwned] = useState<MachineModelDto[]>([])
  const [notOwnedLoading, setNotOwnedLoading] = useState(false)
  const [notOwnedError, setNotOwnedError] = useState("")
  const [copiedSerial, setCopiedSerial] = useState<string>("")
  const [deletingSerial, setDeletingSerial] = useState<string>("")
  const [editingMachineId, setEditingMachineId] = useState<number | null>(null)
  const [edited, setEdited] = useState<Partial<MachineType>>({})
  const [savingMachineId, setSavingMachineId] = useState<number | null>(null)
  const [deletingMachineId, setDeletingMachineId] = useState<number | null>(null)

  const loadNotOwned = async () => {
    setNotOwnedLoading(true)
    setNotOwnedError("")
    const res = await apiClient.getNotOwnedSerialNumbers()
    if (res.error) setNotOwnedError(res.error)
    setNotOwned(res.data || [])
    setNotOwnedLoading(false)
  }

  useEffect(()=>{
    if (activeTab === "not-owned") {
      void loadNotOwned()
    }
  }, [activeTab])

  const handleCopy = async (serial: string) => {
    try {
      await navigator.clipboard.writeText(serial)
      setCopiedSerial(serial)
      setTimeout(()=>setCopiedSerial(""), 1200)
    } catch {
      // noop
    }
  }

  const handleDeleteSerial = async (serial: string) => {
    const clean = serial.trim()
    setDeletingSerial(clean)
    const res = await apiClient.deleteSerialNumber(clean)
    setDeletingSerial("")
    if (res.error) {
      setNotOwnedError(res.error)
      return
    }
    await loadNotOwned()
  }

  const beginEditMachine = (m: MachineType) => {
    setEditingMachineId(m.machine_id)
    setEdited({
      model: m.model,
      serial_number: m.serial_number,
      type: m.type,
      purchase_date: m.purchase_date,
      warranty_end_date: m.warranty_end_date,
      location: m.location,
    })
  }

  const cancelEditMachine = () => {
    setEditingMachineId(null)
    setEdited({})
  }

  const saveEditMachine = async (machineId: number) => {
    setSavingMachineId(machineId)
    const res = await apiClient.updateMachine(String(machineId), edited)
    setSavingMachineId(null)
    if (res.error) {
      alert(res.error)
      return
    }
    cancelEditMachine()
    window.location.reload()
  }

  const handleDeleteMachine = async (machineId: number) => {
    const confirmed = window.confirm("Are you sure you want to delete this machine? This action cannot be undone.")
    if (!confirmed) return
    setDeletingMachineId(machineId)
    const res = await apiClient.deleteMachine(String(machineId))
    setDeletingMachineId(null)
    if (res.error) {
      alert(res.error)
      return
    }
    window.location.reload()
  }

  const filteredMachines = machines.filter(machine => {
    const matchesSearch = machine.serial_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
      machine.model.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         machine.type.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesType = selectedType === "all" || machine.type === selectedType
    return matchesSearch && matchesType
  })

  const getTypeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case "laser":
        return "bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400"
      case "cnc":
        return "bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400"
      case "3d printer":
        return "bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400"
      case "milling":
        return "bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400"
      default:
        return "bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400"
    }
  }

  const formatDate = (dateString?: string) => {
    if (!dateString) return "N/A"
    return new Date(dateString).toLocaleDateString()
  }

  const isWarrantyActive = (warrantyDate?: string) => {
    if (!warrantyDate) return false
    return new Date(warrantyDate) > new Date()
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
                <p className="text-slate-600 dark:text-slate-400">Loading machines...</p>
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
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-4 sm:space-y-0">
              <div>
                <h1 className="text-3xl font-bold text-slate-900 dark:text-slate-100">Machines</h1>
                <p className="text-slate-600 dark:text-slate-400 mt-2">
                  Monitor and manage machine inventory
                </p>  
          </div>
              <div className="flex items-center gap-4">
                <TabsList className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 gap-4">
                  <TabsTrigger value="current" className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">Sold  </TabsTrigger>
                  <TabsTrigger value="not-owned" className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">In Store</TabsTrigger>
                </TabsList>
                <Button 
                  onClick={() => setShowAddForm(true)}
                  className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white"
                >
                <Plus className="h-4 w-4 mr-2" />
                  Add Machine
              </Button>
              </div>
            </div>

            <TabsContent value="current" className="space-y-6">
              {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-blue-100 dark:bg-blue-900/50 rounded-lg">
                    <Server className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {machines.length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Total Machines</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-green-100 dark:bg-green-900/50 rounded-lg">
                    <Server className="h-6 w-6 text-green-600 dark:text-green-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {machines.filter(m => isWarrantyActive(m.warranty_end_date)).length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Under Warranty</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-yellow-100 dark:bg-yellow-900/50 rounded-lg">
                    <Server className="h-6 w-6 text-yellow-600 dark:text-yellow-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {machines.filter(m => !isWarrantyActive(m.warranty_end_date)).length}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Out of Warranty</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
              <CardContent className="p-6">
                <div className="flex items-center space-x-4">
                  <div className="p-3 bg-purple-100 dark:bg-purple-900/50 rounded-lg">
                    <Server className="h-6 w-6 text-purple-600 dark:text-purple-400" />
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-slate-900 dark:text-slate-100">
                      {new Set(machines.map(m => m.type)).size}
                    </p>
                    <p className="text-sm text-slate-600 dark:text-slate-400">Machine Types</p>
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
                    placeholder="Search machines..."
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
                  {Array.from(new Set(machines.map(m => m.type))).map(type => (
                    <option key={type} value={type}>{type}</option>
                  ))}
                </select>
            </div>
          </CardContent>
        </Card>

          {/* Machines Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredMachines.map((machine) => (
              <Card key={machine.machine_id} className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 hover:shadow-lg transition-all duration-200">
                <CardHeader className="pb-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="p-2 bg-gradient-to-br from-blue-100 to-purple-100 dark:from-blue-900/50 dark:to-purple-900/50 rounded-lg">
                        <Server className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                      </div>
                      <div>
                        {editingMachineId === machine.machine_id ? (
                          <div className="space-y-2">
                            <input
                              className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                              value={edited.model || ''}
                              onChange={(e)=>setEdited(v=>({...v, model: e.target.value}))}
                              placeholder="Model"
                            />
                            <input
                              className="w-full rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-3 py-2 text-slate-900 dark:text-slate-100"
                              value={edited.serial_number || ''}
                              onChange={(e)=>setEdited(v=>({...v, serial_number: e.target.value}))}
                              placeholder="Serial Number"
                            />
                          </div>
                        ) : (
                          <>
                            <CardTitle className="text-lg text-slate-900 dark:text-slate-100">
                              {machine.model}
                            </CardTitle>
                            <CardDescription className="text-slate-600 dark:text-slate-400">
                              {machine.serial_number}
                            </CardDescription>
                          </>
                        )}
                      </div>
                    </div>
                    {editingMachineId === machine.machine_id ? (
                      <select
                        className="rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-2 py-1 text-slate-900 dark:text-slate-100"
                        value={edited.type || ''}
                        onChange={(e)=>setEdited(v=>({...v, type: e.target.value}))}
                      >
                        <option value="laser">laser</option>
                        <option value="cnc">cnc</option>
                        <option value="3d printer">3d printer</option>
                        <option value="milling">milling</option>
                      </select>
                    ) : (
                      <Badge className={getTypeColor(machine.type)}>
                        {machine.type}
                      </Badge>
                    )}
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    {editingMachineId === machine.machine_id ? (
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-2">
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="h-4 w-4 text-slate-400" />
                          <input type="date" className="flex-1 rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-2 py-1 text-slate-900 dark:text-slate-100" value={(edited.purchase_date || '').slice(0,10)} onChange={(e)=>setEdited(v=>({...v, purchase_date: e.target.value}))} />
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="h-4 w-4 text-slate-400" />
                          <input type="date" className="flex-1 rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-2 py-1 text-slate-900 dark:text-slate-100" value={(edited.warranty_end_date || '').slice(0,10)} onChange={(e)=>setEdited(v=>({...v, warranty_end_date: e.target.value}))} />
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                          <MapPin className="h-4 w-4 text-slate-400" />
                          <input className="flex-1 rounded-md border border-slate-300 dark:border-slate-700 bg-transparent px-2 py-1 text-slate-900 dark:text-slate-100" value={edited.location || ''} onChange={(e)=>setEdited(v=>({...v, location: e.target.value}))} placeholder="Location" />
                        </div>
                      </div>
                    ) : (
                      <>
                        <div className="flex items-center space-x-2 text-sm">
                          <Calendar className="h-4 w-4 text-slate-400" />
                          <span className="text-slate-600 dark:text-slate-400">Purchase:</span>
                          <span className="text-slate-900 dark:text-slate-100">{formatDate(machine.purchase_date)}</span>
                        </div>
                        <div className="flex items-center space-x-2 text-sm">
                          <Calendar className="h-4 w-4 text-slate-400" />
                          <span className="text-slate-600 dark:text-slate-400">Warranty:</span>
                          <span className={`${isWarrantyActive(machine.warranty_end_date) ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}`}>{formatDate(machine.warranty_end_date)}</span>
                        </div>
                        {machine.location && (
                          <div className="flex items-center space-x-2 text-sm">
                            <MapPin className="h-4 w-4 text-slate-400" />
                            <span className="text-slate-600 dark:text-slate-400">Location:</span>
                            <span className="text-slate-900 dark:text-slate-100">{machine.location}</span>
                          </div>
                        )}
                      </>
                    )}
                  </div>
                  
                  <div className="flex items-center justify-between pt-4 border-t border-slate-200 dark:border-slate-700">
                    <div className="flex items-center space-x-2">
                      {editingMachineId === machine.machine_id ? (
                        <>
                          <Button variant="ghost" size="sm" className="h-8 px-2" onClick={()=>saveEditMachine(machine.machine_id)} disabled={savingMachineId === machine.machine_id}>
                            {savingMachineId === machine.machine_id ? 'Saving...' : 'Save'}
                          </Button>
                          <Button variant="ghost" size="sm" className="h-8 px-2" onClick={cancelEditMachine}>
                            Cancel
                          </Button>
                        </>
                      ) : (
                        <>
                          <Button variant="ghost" size="sm" className="h-8 w-8 p-0" onClick={()=>beginEditMachine(machine)}>
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                            <Settings className="h-4 w-4" />
                          </Button>
                        </>
                      )}
                    </div>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="h-8 w-8 p-0 text-red-600 hover:text-red-700"
                      onClick={()=>handleDeleteMachine(machine.machine_id)}
                      disabled={deletingMachineId === machine.machine_id}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
          </CardContent>
        </Card>
            ))}
                </div>

          {filteredMachines.length === 0 && (
            <div className="text-center py-12">
              <Server className="h-12 w-12 text-slate-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-slate-900 dark:text-slate-100 mb-2">
                No machines found
              </h3>
              <p className="text-slate-600 dark:text-slate-400">
                Try adjusting your search or filter criteria.
              </p>
            </div>
                    )}
            </TabsContent>

            <TabsContent value="not-owned" className="space-y-6">
              <Card className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50">
                <CardHeader>
                  <CardTitle className="text-2xl font-bold text-slate-900 dark:text-slate-100">Available Serial Numbers</CardTitle>
                  <CardDescription className="text-slate-600 dark:text-slate-400" >Serial numbers not yet owned</CardDescription>
                </CardHeader>
                <CardContent>
                  {notOwnedLoading && (
                    <div className="flex items-center justify-center py-10 text-slate-500">Loading...</div>
                  )}
                  {notOwnedError && (
                    <div className="text-red-600 dark:text-red-400 py-2">{notOwnedError}</div>
                  )}
                  {!notOwnedLoading && !notOwnedError && (
                    <div className="grid grid-cols-2 gap-3">
                      {notOwned.map(item => (
                        <Card key={item.serial_number} className="bg-white/80 dark:bg-slate-800/80 backdrop-blur-xl border-slate-200/50 dark:border-slate-700/50 w-full">
                          <CardContent className="p-3 flex items-center justify-between gap-4">
                            <div className="flex items-center gap-4 min-w-0">
                              <div className="flex flex-col gap-4">
                                <div className="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400">Serial</div>
                                <div className="font-semibold text-slate-900 dark:text-slate-100 text-base truncate max-w-[48ch]">{item.serial_number}</div>
                                {(item.model || item.type) && (
                                  <div className="text-xs text-slate-600 dark:text-slate-400 truncate max-w-[48ch]">
                                    {item.model || '—'} {item.type ? `• ${item.type}` : ''}
                </div>
                                )}
              </div>
                              <Button variant="outline" size="sm" onClick={() => handleCopy(item.serial_number)}>
                                {copiedSerial === item.serial_number ? 'Copied' : 'Copy'}
                              </Button>
                </div>
                            <div className="flex items-center gap-2 shrink-0">                              
                              <Button 
                                variant="destructive" 
                                size="sm" 
                                disabled={deletingSerial === item.serial_number}
                                onClick={() => handleDeleteSerial(item.serial_number)}
                              >
                                {deletingSerial === item.serial_number ? 'Deleting...' : 'Delete'}
                              </Button>
                </div>
                          </CardContent>
                        </Card>
                      ))}
                </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>

          {/* Add Machine Form Modal */}
      {showAddForm && (
        <AddMachineForm
          onClose={() => setShowAddForm(false)}
          onSuccess={() => {
            // Refresh the machines list
            window.location.reload()
          }}
        />
      )}
    </main>
            </div>
    </div>
  )
}
