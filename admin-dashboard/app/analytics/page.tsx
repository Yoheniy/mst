"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  AreaChart,
  Area,
} from "recharts"
import {
  BarChart3,
  ArrowLeft,
  TrendingUp,
  TrendingDown,
  Users,
  Server,
  BookOpen,
  Ticket,
  Download,
  Calendar,
  Activity,
} from "lucide-react"
import Link from "next/link"

// Mock analytics data
const userGrowthData = [
  { month: "Jan", users: 2400, active: 2100 },
  { month: "Feb", users: 2600, active: 2300 },
  { month: "Mar", users: 2800, active: 2500 },
  { month: "Apr", users: 3000, active: 2700 },
  { month: "May", users: 3200, active: 2900 },
  { month: "Jun", users: 3400, active: 3100 },
]

const ticketTrendsData = [
  { week: "Week 1", open: 45, resolved: 38, closed: 42 },
  { week: "Week 2", open: 52, resolved: 45, closed: 48 },
  { week: "Week 3", open: 38, resolved: 52, closed: 35 },
  { week: "Week 4", open: 41, resolved: 48, closed: 44 },
]

const machineStatusData = [
  { name: "Active", value: 1234, color: "#84cc16" },
  { name: "Maintenance", value: 89, color: "#15803d" },
  { name: "Inactive", value: 45, color: "#6b7280" },
  { name: "Retired", value: 23, color: "#dc2626" },
]

const knowledgeBaseData = [
  { category: "Setup Guide", articles: 45, views: 12500 },
  { category: "Troubleshooting", articles: 38, views: 18200 },
  { category: "Maintenance", articles: 32, views: 9800 },
  { category: "Safety", articles: 28, views: 15600 },
  { category: "Technical", articles: 25, views: 7400 },
  { category: "FAQ", articles: 42, views: 22100 },
]

const dailyActivityData = [
  { time: "00:00", users: 12, tickets: 2, articles: 5 },
  { time: "04:00", users: 8, tickets: 1, articles: 3 },
  { time: "08:00", users: 145, tickets: 15, articles: 28 },
  { time: "12:00", users: 234, tickets: 25, articles: 45 },
  { time: "16:00", users: 189, tickets: 18, articles: 32 },
  { time: "20:00", users: 67, tickets: 8, articles: 15 },
]

const priorityDistribution = [
  { name: "Low", value: 45, color: "#6b7280" },
  { name: "Medium", value: 78, color: "#84cc16" },
  { name: "High", value: 32, color: "#15803d" },
  { name: "Critical", value: 12, color: "#dc2626" },
]

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState("30d")
  const [selectedMetric, setSelectedMetric] = useState("overview")

  const exportData = () => {
    // Simulate data export
    const data = {
      users: userGrowthData,
      tickets: ticketTrendsData,
      machines: machineStatusData,
      knowledge: knowledgeBaseData,
      activity: dailyActivityData,
      priority: priorityDistribution,
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `analytics-${timeRange}-${new Date().toISOString().split("T")[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
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
              Analytics Dashboard
            </h1>
          </div>
          <div className="flex items-center space-x-4">
            <Select value={timeRange} onValueChange={setTimeRange}>
              <SelectTrigger className="w-[140px]">
                <Calendar className="h-4 w-4 mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="7d">Last 7 days</SelectItem>
                <SelectItem value="30d">Last 30 days</SelectItem>
                <SelectItem value="90d">Last 90 days</SelectItem>
                <SelectItem value="1y">Last year</SelectItem>
              </SelectContent>
            </Select>
            <Button onClick={exportData} variant="outline" size="sm">
              <Download className="h-4 w-4 mr-2" />
              Export Data
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="p-6">
        {/* Key Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Total Users</CardTitle>
              <Users className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">3,400</div>
              <div className="flex items-center text-xs text-accent">
                <TrendingUp className="h-3 w-3 mr-1" />
                +12.5% from last month
              </div>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Active Machines</CardTitle>
              <Server className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">1,391</div>
              <div className="flex items-center text-xs text-accent">
                <TrendingUp className="h-3 w-3 mr-1" />
                +5.2% from last month
              </div>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Knowledge Views</CardTitle>
              <BookOpen className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">85,600</div>
              <div className="flex items-center text-xs text-accent">
                <TrendingUp className="h-3 w-3 mr-1" />
                +18.3% from last month
              </div>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">Ticket Resolution Rate</CardTitle>
              <Ticket className="h-4 w-4 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">94.2%</div>
              <div className="flex items-center text-xs text-destructive">
                <TrendingDown className="h-3 w-3 mr-1" />
                -2.1% from last month
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* User Growth Chart */}
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">User Growth</CardTitle>
              <CardDescription className="text-muted-foreground">
                Total users and active users over time
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={userGrowthData}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                  <XAxis dataKey="month" className="text-muted-foreground" />
                  <YAxis className="text-muted-foreground" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                  <Legend />
                  <Area
                    type="monotone"
                    dataKey="users"
                    stackId="1"
                    stroke="hsl(var(--primary))"
                    fill="hsl(var(--primary))"
                    fillOpacity={0.6}
                    name="Total Users"
                  />
                  <Area
                    type="monotone"
                    dataKey="active"
                    stackId="2"
                    stroke="hsl(var(--accent))"
                    fill="hsl(var(--accent))"
                    fillOpacity={0.6}
                    name="Active Users"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Ticket Trends Chart */}
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">Ticket Trends</CardTitle>
              <CardDescription className="text-muted-foreground">
                Support ticket status over the last 4 weeks
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={ticketTrendsData}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                  <XAxis dataKey="week" className="text-muted-foreground" />
                  <YAxis className="text-muted-foreground" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                  <Legend />
                  <Bar dataKey="open" fill="hsl(var(--destructive))" name="Open" />
                  <Bar dataKey="resolved" fill="hsl(var(--accent))" name="Resolved" />
                  <Bar dataKey="closed" fill="hsl(var(--primary))" name="Closed" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Machine Status and Priority Distribution */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Machine Status Distribution */}
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">
                Machine Status Distribution
              </CardTitle>
              <CardDescription className="text-muted-foreground">Current status of all machines</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={machineStatusData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {machineStatusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          {/* Ticket Priority Distribution */}
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">
                Ticket Priority Distribution
              </CardTitle>
              <CardDescription className="text-muted-foreground">Current open tickets by priority</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={priorityDistribution}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {priorityDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{
                      backgroundColor: "hsl(var(--card))",
                      border: "1px solid hsl(var(--border))",
                      borderRadius: "8px",
                    }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>

        {/* Knowledge Base Analytics */}
        <Card className="bg-card border-border mb-8">
          <CardHeader>
            <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">
              Knowledge Base Analytics
            </CardTitle>
            <CardDescription className="text-muted-foreground">
              Article count and view statistics by category
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={400}>
              <BarChart data={knowledgeBaseData} layout="horizontal">
                <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                <XAxis type="number" className="text-muted-foreground" />
                <YAxis dataKey="category" type="category" width={100} className="text-muted-foreground" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "hsl(var(--card))",
                    border: "1px solid hsl(var(--border))",
                    borderRadius: "8px",
                  }}
                />
                <Legend />
                <Bar dataKey="articles" fill="hsl(var(--primary))" name="Articles" />
                <Bar dataKey="views" fill="hsl(var(--accent))" name="Views" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Daily Activity Chart */}
        <Card className="bg-card border-border mb-8">
          <CardHeader>
            <CardTitle className="text-foreground font-[family-name:var(--font-playfair)]">Daily Activity</CardTitle>
            <CardDescription className="text-muted-foreground">
              User activity, ticket creation, and article views throughout the day
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={dailyActivityData}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                <XAxis dataKey="time" className="text-muted-foreground" />
                <YAxis className="text-muted-foreground" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "hsl(var(--card))",
                    border: "1px solid hsl(var(--border))",
                    borderRadius: "8px",
                  }}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="users"
                  stroke="hsl(var(--primary))"
                  strokeWidth={2}
                  name="Active Users"
                />
                <Line
                  type="monotone"
                  dataKey="tickets"
                  stroke="hsl(var(--destructive))"
                  strokeWidth={2}
                  name="New Tickets"
                />
                <Line
                  type="monotone"
                  dataKey="articles"
                  stroke="hsl(var(--accent))"
                  strokeWidth={2}
                  name="Article Views"
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)] flex items-center">
                <Activity className="h-5 w-5 mr-2 text-primary" />
                System Health
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Uptime</span>
                  <Badge className="bg-accent text-accent-foreground">99.9%</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Response Time</span>
                  <Badge className="bg-accent text-accent-foreground">145ms</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Error Rate</span>
                  <Badge className="bg-accent text-accent-foreground">0.1%</Badge>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)] flex items-center">
                <TrendingUp className="h-5 w-5 mr-2 text-primary" />
                Performance Metrics
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Avg. Resolution Time</span>
                  <Badge className="bg-secondary text-secondary-foreground">2.4 hours</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Customer Satisfaction</span>
                  <Badge className="bg-accent text-accent-foreground">4.8/5</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">First Response Time</span>
                  <Badge className="bg-accent text-accent-foreground">12 min</Badge>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-card border-border">
            <CardHeader>
              <CardTitle className="text-foreground font-[family-name:var(--font-playfair)] flex items-center">
                <BarChart3 className="h-5 w-5 mr-2 text-primary" />
                Growth Insights
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Monthly Growth</span>
                  <Badge className="bg-accent text-accent-foreground">+12.5%</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">New Registrations</span>
                  <Badge className="bg-secondary text-secondary-foreground">+234</Badge>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-muted-foreground">Retention Rate</span>
                  <Badge className="bg-accent text-accent-foreground">87.3%</Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </main>
    </div>
  )
}
