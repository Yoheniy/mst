"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import {
  Ticket,
  Plus,
  Search,
  Edit,
  Trash2,
  ArrowLeft,
  Filter,
  MessageSquare,
  Clock,
  User,
  AlertTriangle,
} from "lucide-react"
import Link from "next/link"

// Mock ticket data
const mockTickets = [
  {
    id: 1,
    ticketNumber: "TK-2024-001",
    title: "Machine not starting properly",
    description:
      "The industrial printer is not starting up after the latest maintenance. Error code E-404 appears on display.",
    status: "Open",
    priority: "High",
    customer: "John Smith",
    customerId: 1,
    assignedTo: "Sarah Johnson",
    assigneeId: 2,
    category: "Hardware",
    createdDate: "2024-01-15",
    lastUpdated: "2024-01-15",
    dueDate: "2024-01-17",
    responses: 0,
    machineId: "MX-2024-001",
  },
  {
    id: 2,
    ticketNumber: "TK-2024-002",
    title: "Software license expiration",
    description: "Our software license is expiring next week and we need to renew it to continue operations.",
    status: "In Progress",
    priority: "Medium",
    customer: "Mike Wilson",
    customerId: 3,
    assignedTo: "Emily Davis",
    assigneeId: 4,
    category: "Software",
    createdDate: "2024-01-12",
    lastUpdated: "2024-01-14",
    dueDate: "2024-01-19",
    responses: 3,
    machineId: null,
  },
  {
    id: 3,
    ticketNumber: "TK-2024-003",
    title: "Request for training materials",
    description: "We need updated training materials for the new machine operators joining our team.",
    status: "Resolved",
    priority: "Low",
    customer: "Robert Brown",
    customerId: 5,
    assignedTo: "Sarah Johnson",
    assigneeId: 2,
    category: "Training",
    createdDate: "2024-01-10",
    lastUpdated: "2024-01-13",
    dueDate: "2024-01-20",
    responses: 5,
    machineId: null,
  },
  {
    id: 4,
    ticketNumber: "TK-2024-004",
    title: "Critical system failure",
    description: "Complete system shutdown occurred during production. Immediate assistance required.",
    status: "Open",
    priority: "Critical",
    customer: "Emily Davis",
    customerId: 4,
    assignedTo: "Mike Wilson",
    assigneeId: 3,
    category: "Hardware",
    createdDate: "2024-01-14",
    lastUpdated: "2024-01-14",
    dueDate: "2024-01-15",
    responses: 1,
    machineId: "MX-2023-045",
  },
  {
    id: 5,
    ticketNumber: "TK-2024-005",
    title: "API integration support",
    description: "Need help integrating our system with the new API endpoints for data synchronization.",
    status: "Closed",
    priority: "Medium",
    customer: "John Smith",
    customerId: 1,
    assignedTo: "Robert Brown",
    assigneeId: 5,
    category: "Technical",
    createdDate: "2024-01-08",
    lastUpdated: "2024-01-12",
    dueDate: "2024-01-15",
    responses: 8,
    machineId: null,
  },
]

const mockUsers = [
  { id: 1, name: "John Smith", role: "Customer" },
  { id: 2, name: "Sarah Johnson", role: "Technician" },
  { id: 3, name: "Mike Wilson", role: "Technician" },
  { id: 4, name: "Emily Davis", role: "Technician" },
  { id: 5, name: "Robert Brown", role: "Customer" },
]

const categories = ["Hardware", "Software", "Training", "Technical", "Billing", "General"]
const priorities = ["Low", "Medium", "High", "Critical"]
const statuses = ["Open", "In Progress", "Resolved", "Closed"]

export default function TicketsPage() {
  const [tickets, setTickets] = useState(mockTickets)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [priorityFilter, setPriorityFilter] = useState("all")
  const [categoryFilter, setCategoryFilter] = useState("all")
  const [assigneeFilter, setAssigneeFilter] = useState("all")
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false)
  const [selectedTicket, setSelectedTicket] = useState<any>(null)
  const [formData, setFormData] = useState({
    title: "",
    description: "",
    priority: "Medium",
    customerId: "",
    assigneeId: "",
    category: "",
    dueDate: "",
    machineId: "",
  })

  // Get technicians for assignment
  const technicians = mockUsers.filter((user) => user.role === "Technician")
  const customers = mockUsers.filter((user) => user.role === "Customer")

  // Filter tickets based on search and filters
  const filteredTickets = tickets.filter((ticket) => {
    const matchesSearch =
      ticket.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      ticket.ticketNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
      ticket.customer.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || ticket.status === statusFilter
    const matchesPriority = priorityFilter === "all" || ticket.priority === priorityFilter
    const matchesCategory = categoryFilter === "all" || ticket.category === categoryFilter
    const matchesAssignee = assigneeFilter === "all" || ticket.assigneeId.toString() === assigneeFilter
    return matchesSearch && matchesStatus && matchesPriority && matchesCategory && matchesAssignee
  })

  const handleCreateTicket = () => {
    const selectedCustomer = mockUsers.find((u) => u.id === Number.parseInt(formData.customerId))
    const selectedAssignee = mockUsers.find((u) => u.id === Number.parseInt(formData.assigneeId))
    const ticketNumber = `TK-2024-${String(tickets.length + 1).padStart(3, "0")}`

    const newTicket = {
      id: tickets.length + 1,
      ticketNumber,
      title: formData.title,
      description: formData.description,
      status: "Open",
      priority: formData.priority,
      customer: selectedCustomer?.name || "",
      customerId: Number.parseInt(formData.customerId),
      assignedTo: selectedAssignee?.name || "",
      assigneeId: Number.parseInt(formData.assigneeId),
      category: formData.category,
      createdDate: new Date().toISOString().split("T")[0],
      lastUpdated: new Date().toISOString().split("T")[0],
      dueDate: formData.dueDate,
      responses: 0,
      machineId: formData.machineId || null,
    }

    setTickets([...tickets, newTicket])
    setFormData({
      title: "",
      description: "",
      priority: "Medium",
      customerId: "",
      assigneeId: "",
      category: "",
      dueDate: "",
      machineId: "",
    })
    setIsCreateDialogOpen(false)
  }

  const handleEditTicket = () => {
    const selectedCustomer = mockUsers.find((u) => u.id === Number.parseInt(formData.customerId))
    const selectedAssignee = mockUsers.find((u) => u.id === Number.parseInt(formData.assigneeId))

    setTickets(
      tickets.map((ticket) =>
        ticket.id === selectedTicket.id
          ? {
              ...ticket,
              title: formData.title,
              description: formData.description,
              priority: formData.priority,
              customer: selectedCustomer?.name || ticket.customer,
              customerId: Number.parseInt(formData.customerId),
              assignedTo: selectedAssignee?.name || ticket.assignedTo,
              assigneeId: Number.parseInt(formData.assigneeId),
              category: formData.category,
              dueDate: formData.dueDate,
              machineId: formData.machineId || null,
              lastUpdated: new Date().toISOString().split("T")[0],
            }
          : ticket,
      ),
    )
    setIsEditDialogOpen(false)
    setSelectedTicket(null)
    setFormData({
      title: "",
      description: "",
      priority: "Medium",
      customerId: "",
      assigneeId: "",
      category: "",
      dueDate: "",
      machineId: "",
    })
  }

  const handleDeleteTicket = (ticketId: number) => {
    setTickets(tickets.filter((ticket) => ticket.id !== ticketId))
  }

  const handleStatusChange = (ticketId: number, newStatus: string) => {
    setTickets(
      tickets.map((ticket) =>
        ticket.id === ticketId
          ? { ...ticket, status: newStatus, lastUpdated: new Date().toISOString().split("T")[0] }
          : ticket,
      ),
    )
  }

  const openEditDialog = (ticket: any) => {
    setSelectedTicket(ticket)
    setFormData({
      title: ticket.title,
      description: ticket.description,
      priority: ticket.priority,
      customerId: ticket.customerId.toString(),
      assigneeId: ticket.assigneeId.toString(),
      category: ticket.category,
      dueDate: ticket.dueDate,
      machineId: ticket.machineId || "",
    })
    setIsEditDialogOpen(true)
  }

  const openViewDialog = (ticket: any) => {
    setSelectedTicket(ticket)
    setIsViewDialogOpen(true)
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "Critical":
        return "bg-destructive text-destructive-foreground"
      case "High":
        return "bg-secondary text-secondary-foreground"
      case "Medium":
        return "bg-accent text-accent-foreground"
      case "Low":
        return "bg-muted text-muted-foreground"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Open":
        return "bg-destructive text-destructive-foreground"
      case "In Progress":
        return "bg-secondary text-secondary-foreground"
      case "Resolved":
        return "bg-accent text-accent-foreground"
      case "Closed":
        return "bg-muted text-muted-foreground"
      default:
        return "bg-muted text-muted-foreground"
    }
  }

  const isOverdue = (dueDate: string, status: string) => {
    if (status === "Closed" || status === "Resolved") return false
    const due = new Date(dueDate)
    const today = new Date()
    return due < today
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="flex h-16 items-center justify-between px-6">
          <div className="flex items-center space-x-4">
            <Link href="/">
              <Button variant="ghost" size="sm">
                <ArrowLeft className="h-4 w-4 mr-2" />
                Back to Dashboard
              </Button>
            </Link>
            <h1 className="text-2xl font-bold text-foreground font-[family-name:var(--font-playfair)]">
              Support Ticket System
            </h1>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button className="bg-primary text-primary-foreground hover:bg-primary/90">
                <Plus className="h-4 w-4 mr-2" />
                Create Ticket
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Create New Support Ticket</DialogTitle>
                <DialogDescription>Create a new support ticket for customer assistance.</DialogDescription>
              </DialogHeader>
              <div className="grid gap-4 py-4">
                <div className="grid gap-2">
                  <Label htmlFor="title">Title</Label>
                  <Input
                    id="title"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    placeholder="Brief description of the issue"
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    placeholder="Detailed description of the issue..."
                    rows={4}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="grid gap-2">
                    <Label htmlFor="customer">Customer</Label>
                    <Select
                      value={formData.customerId}
                      onValueChange={(value) => setFormData({ ...formData, customerId: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select customer" />
                      </SelectTrigger>
                      <SelectContent>
                        {customers.map((customer) => (
                          <SelectItem key={customer.id} value={customer.id.toString()}>
                            {customer.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="assignee">Assign To</Label>
                    <Select
                      value={formData.assigneeId}
                      onValueChange={(value) => setFormData({ ...formData, assigneeId: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select technician" />
                      </SelectTrigger>
                      <SelectContent>
                        {technicians.map((tech) => (
                          <SelectItem key={tech.id} value={tech.id.toString()}>
                            {tech.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-4">
                  <div className="grid gap-2">
                    <Label htmlFor="priority">Priority</Label>
                    <Select
                      value={formData.priority}
                      onValueChange={(value) => setFormData({ ...formData, priority: value })}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        {priorities.map((priority) => (
                          <SelectItem key={priority} value={priority}>
                            {priority}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="category">Category</Label>
                    <Select
                      value={formData.category}
                      onValueChange={(value) => setFormData({ ...formData, category: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select category" />
                      </SelectTrigger>
                      <SelectContent>
                        {categories.map((category) => (
                          <SelectItem key={category} value={category}>
                            {category}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid gap-2">
                    <Label htmlFor="dueDate">Due Date</Label>
                    <Input
                      id="dueDate"
                      type="date"
                      value={formData.dueDate}
                      onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                    />
                  </div>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="machineId">Related Machine (Optional)</Label>
                  <Input
                    id="machineId"
                    value={formData.machineId}
                    onChange={(e) => setFormData({ ...formData, machineId: e.target.value })}
                    placeholder="MX-2024-001"
                  />
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                  Cancel
                </Button>
                <Button onClick={handleCreateTicket} className="bg-primary text-primary-foreground">
                  Create Ticket
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </header>

      {/* Main Content */}
      <main className="p-6">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-6">
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Total Tickets</CardTitle>
              <Ticket className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">{tickets.length}</div>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Open</CardTitle>
              <Ticket className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">
                {tickets.filter((t) => t.status === "Open").length}
              </div>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">In Progress</CardTitle>
              <Clock className="h-4 w-4 text-secondary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">
                {tickets.filter((t) => t.status === "In Progress").length}
              </div>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Critical</CardTitle>
              <AlertTriangle className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">
                {tickets.filter((t) => t.priority === "Critical").length}
              </div>
            </CardContent>
          </Card>
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Overdue</CardTitle>
              <Clock className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">
                {tickets.filter((t) => isOverdue(t.dueDate, t.status)).length}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Filters and Search */}
        <Card className="bg-card border-border mb-6">
          <CardHeader>
            <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">
              Search & Filter Tickets
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col md:flex-row gap-4">
              <div className="flex-1">
                <div className="relative">
                  <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Search by title, ticket number, or customer..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="pl-10"
                  />
                </div>
              </div>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-full md:w-[150px]">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  {statuses.map((status) => (
                    <SelectItem key={status} value={status}>
                      {status}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select value={priorityFilter} onValueChange={setPriorityFilter}>
                <SelectTrigger className="w-full md:w-[150px]">
                  <SelectValue placeholder="Priority" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Priority</SelectItem>
                  {priorities.map((priority) => (
                    <SelectItem key={priority} value={priority}>
                      {priority}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select value={categoryFilter} onValueChange={setCategoryFilter}>
                <SelectTrigger className="w-full md:w-[150px]">
                  <SelectValue placeholder="Category" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Categories</SelectItem>
                  {categories.map((category) => (
                    <SelectItem key={category} value={category}>
                      {category}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select value={assigneeFilter} onValueChange={setAssigneeFilter}>
                <SelectTrigger className="w-full md:w-[150px]">
                  <SelectValue placeholder="Assignee" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Assignees</SelectItem>
                  {technicians.map((tech) => (
                    <SelectItem key={tech.id} value={tech.id.toString()}>
                      {tech.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Tickets Table */}
        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">
              Support Tickets ({filteredTickets.length})
            </CardTitle>
            <CardDescription className="text-muted-foreground">
              Handle customer support requests and track resolution progress
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-muted-foreground">Ticket #</TableHead>
                  <TableHead className="text-muted-foreground">Title</TableHead>
                  <TableHead className="text-muted-foreground">Customer</TableHead>
                  <TableHead className="text-muted-foreground">Priority</TableHead>
                  <TableHead className="text-muted-foreground">Status</TableHead>
                  <TableHead className="text-muted-foreground">Assigned To</TableHead>
                  <TableHead className="text-muted-foreground">Category</TableHead>
                  <TableHead className="text-muted-foreground">Due Date</TableHead>
                  <TableHead className="text-muted-foreground">Responses</TableHead>
                  <TableHead className="text-muted-foreground">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredTickets.map((ticket) => (
                  <TableRow key={ticket.id} className="hover:bg-muted/50">
                    <TableCell className="font-medium text-foreground">{ticket.ticketNumber}</TableCell>
                    <TableCell className="max-w-xs">
                      <div className="truncate font-medium text-foreground">{ticket.title}</div>
                      {ticket.machineId && (
                        <div className="text-xs text-muted-foreground">Machine: {ticket.machineId}</div>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center">
                        <User className="h-4 w-4 mr-2 text-muted-foreground" />
                        <span className="text-foreground">{ticket.customer}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className={getPriorityColor(ticket.priority)}>{ticket.priority}</Badge>
                    </TableCell>
                    <TableCell>
                      <Select value={ticket.status} onValueChange={(value) => handleStatusChange(ticket.id, value)}>
                        <SelectTrigger className="w-32">
                          <Badge className={getStatusColor(ticket.status)}>{ticket.status}</Badge>
                        </SelectTrigger>
                        <SelectContent>
                          {statuses.map((status) => (
                            <SelectItem key={status} value={status}>
                              {status}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </TableCell>
                    <TableCell className="text-foreground">{ticket.assignedTo}</TableCell>
                    <TableCell className="text-muted-foreground">{ticket.category}</TableCell>
                    <TableCell>
                      <span
                        className={
                          isOverdue(ticket.dueDate, ticket.status)
                            ? "text-destructive font-medium"
                            : "text-muted-foreground"
                        }
                      >
                        {ticket.dueDate}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center">
                        <MessageSquare className="h-4 w-4 mr-2 text-muted-foreground" />
                        <span className="text-foreground">{ticket.responses}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex space-x-2">
                        <Button variant="outline" size="sm" onClick={() => openViewDialog(ticket)}>
                          <MessageSquare className="h-4 w-4" />
                        </Button>
                        <Button variant="outline" size="sm" onClick={() => openEditDialog(ticket)}>
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => handleDeleteTicket(ticket.id)}
                          className="text-destructive hover:text-destructive"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* View Ticket Dialog */}
        <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
          <DialogContent className="max-w-4xl">
            <DialogHeader>
              <DialogTitle className="flex items-center gap-2">
                <Ticket className="h-5 w-5" />
                {selectedTicket?.ticketNumber} - {selectedTicket?.title}
              </DialogTitle>
              <DialogDescription>
                <div className="flex items-center gap-4 mt-2">
                  <Badge className={selectedTicket && getPriorityColor(selectedTicket.priority)}>
                    {selectedTicket?.priority}
                  </Badge>
                  <Badge className={selectedTicket && getStatusColor(selectedTicket.status)}>
                    {selectedTicket?.status}
                  </Badge>
                  <span>Customer: {selectedTicket?.customer}</span>
                  <span>Assigned to: {selectedTicket?.assignedTo}</span>
                </div>
              </DialogDescription>
            </DialogHeader>
            <div className="py-4">
              <div className="grid grid-cols-2 gap-6 mb-6">
                <div>
                  <h4 className="text-sm font-medium text-muted-foreground mb-2">Ticket Details</h4>
                  <div className="space-y-2 text-sm">
                    <div>
                      <strong>Category:</strong> {selectedTicket?.category}
                    </div>
                    <div>
                      <strong>Created:</strong> {selectedTicket?.createdDate}
                    </div>
                    <div>
                      <strong>Due Date:</strong> {selectedTicket?.dueDate}
                    </div>
                    <div>
                      <strong>Last Updated:</strong> {selectedTicket?.lastUpdated}
                    </div>
                    {selectedTicket?.machineId && (
                      <div>
                        <strong>Related Machine:</strong> {selectedTicket.machineId}
                      </div>
                    )}
                  </div>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-muted-foreground mb-2">Communication</h4>
                  <div className="space-y-2 text-sm">
                    <div>
                      <strong>Responses:</strong> {selectedTicket?.responses}
                    </div>
                    <div>
                      <strong>Status:</strong> {selectedTicket?.status}
                    </div>
                  </div>
                </div>
              </div>
              <div>
                <h4 className="text-sm font-medium text-muted-foreground mb-2">Description</h4>
                <div className="bg-muted p-4 rounded-lg">
                  <p className="text-foreground whitespace-pre-wrap">{selectedTicket?.description}</p>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsViewDialogOpen(false)}>
                Close
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit Ticket Dialog */}
        <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Edit Support Ticket</DialogTitle>
              <DialogDescription>Update ticket information and assignment.</DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label htmlFor="edit-title">Title</Label>
                <Input
                  id="edit-title"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="edit-description">Description</Label>
                <Textarea
                  id="edit-description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={4}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="edit-customer">Customer</Label>
                  <Select
                    value={formData.customerId}
                    onValueChange={(value) => setFormData({ ...formData, customerId: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {customers.map((customer) => (
                        <SelectItem key={customer.id} value={customer.id.toString()}>
                          {customer.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-assignee">Assign To</Label>
                  <Select
                    value={formData.assigneeId}
                    onValueChange={(value) => setFormData({ ...formData, assigneeId: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {technicians.map((tech) => (
                        <SelectItem key={tech.id} value={tech.id.toString()}>
                          {tech.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="grid grid-cols-3 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="edit-priority">Priority</Label>
                  <Select
                    value={formData.priority}
                    onValueChange={(value) => setFormData({ ...formData, priority: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {priorities.map((priority) => (
                        <SelectItem key={priority} value={priority}>
                          {priority}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-category">Category</Label>
                  <Select
                    value={formData.category}
                    onValueChange={(value) => setFormData({ ...formData, category: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {categories.map((category) => (
                        <SelectItem key={category} value={category}>
                          {category}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-dueDate">Due Date</Label>
                  <Input
                    id="edit-dueDate"
                    type="date"
                    value={formData.dueDate}
                    onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                  />
                </div>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="edit-machineId">Related Machine (Optional)</Label>
                <Input
                  id="edit-machineId"
                  value={formData.machineId}
                  onChange={(e) => setFormData({ ...formData, machineId: e.target.value })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleEditTicket} className="bg-primary text-primary-foreground">
                Save Changes
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </main>
    </div>
  )
}
