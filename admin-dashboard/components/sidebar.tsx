"use client"

import { useState } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { ScrollArea } from "@/components/ui/scroll-area"
import { 
  Users, 
  Server, 
  BookOpen, 
  Ticket, 
  BarChart3, 
  Settings, 
  Home,
  ChevronLeft,
  Menu,
  X,
  AlertTriangle
} from "lucide-react"
import { useAuth } from "@/components/auth-provider"

interface SidebarItem {
  title: string
  href: string
  icon: React.ComponentType<{ className?: string }>
  badge?: string
  adminOnly?: boolean
}

const sidebarItems: SidebarItem[] = [
  {
    title: "Dashboard",
    href: "/",
    icon: Home,
  },
  {
    title: "Users",
    href: "/users",
    icon: Users,
    // Make visible to all (remove adminOnly)
  },
  {
    title: "Machines",
    href: "/machines",
    icon: Server,
  },
  {
    title: "Knowledge Base",
    href: "/knowledge",
    icon: BookOpen,
  },
  {
    title: "Error Codes",
    href: "/error-codes",
    icon: AlertTriangle,
  },
  {
    title: "Tickets",
    href: "/tickets",
    icon: Ticket,
    badge: "12",
  }
]

export function Sidebar() {
  const [isCollapsed, setIsCollapsed] = useState(false)
  const [isMobileOpen, setIsMobileOpen] = useState(false)
  const pathname = usePathname()
  const { user } = useAuth()

  const filteredItems = sidebarItems.filter(item => 
    !item.adminOnly || (user?.role && String(user.role).toLowerCase() === "admin")
  )

  return (
    <>
      {/* Mobile menu button */}
      <Button
        variant="ghost"
        size="sm"
        className="md:hidden fixed top-4 left-4 z-50"
        onClick={() => setIsMobileOpen(!isMobileOpen)}
      >
        {isMobileOpen ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
      </Button>

      {/* Mobile overlay */}
      {isMobileOpen && (
        <div 
          className="fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={() => setIsMobileOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div className={cn(
        "fixed left-0 top-0 z-40 h-full transition-all duration-300 ease-in-out",
        "bg-gradient-to-b from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800",
        "border-r border-slate-200 dark:border-slate-700",
        isCollapsed ? "w-16" : "w-64",
        isMobileOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
      )}>
        <div className="flex h-full flex-col">
          {/* Logo */}
          <div className="flex h-16 items-center justify-between px-4 border-b border-slate-200 dark:border-slate-700">
            <div className="flex items-center space-x-3">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-gradient-to-r from-blue-600 to-purple-600">
                <Server className="h-5 w-5 text-white" />
              </div>
              {!isCollapsed && (
                <span className="text-lg font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                  Admin
                </span>
              )}
            </div>
            <Button
              variant="ghost"
              size="sm"
              className="hidden md:flex h-8 w-8 p-0"
              onClick={() => setIsCollapsed(!isCollapsed)}
            >
              <ChevronLeft className={cn(
                "h-4 w-4 transition-transform",
                isCollapsed && "rotate-180"
              )} />
            </Button>
          </div>

          {/* Navigation */}
          <ScrollArea className="flex-1 px-3 py-4">
            <nav className="space-y-2">
              {filteredItems.map((item) => {
                const isActive = pathname === item.href
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={() => setIsMobileOpen(false)}
                    className={cn(
                      "flex items-center space-x-3 rounded-lg px-3 py-2 text-sm font-medium transition-all duration-200",
                      "hover:bg-slate-200/50 dark:hover:bg-slate-700/50",
                      "group relative overflow-hidden",
                      isActive 
                        ? "bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg" 
                        : "text-slate-700 dark:text-slate-300"
                    )}
                  >
                    <item.icon className={cn(
                      "h-4 w-4 transition-transform group-hover:scale-110",
                      isActive ? "text-white" : "text-slate-500 dark:text-slate-400"
                    )} />
                    {!isCollapsed && (
                      <>
                        <span className="flex-1">{item.title}</span>
                        {item.badge && (
                          <span className="inline-flex items-center justify-center px-2 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                            {item.badge}
                          </span>
                        )}
                      </>
                    )}
                    {isActive && (
                      <div className="absolute inset-0 bg-gradient-to-r from-blue-600/20 to-purple-600/20 animate-pulse" />
                    )}
                  </Link>
                )
              })}
            </nav>
          </ScrollArea>

          {/* User info */}
          {!isCollapsed && (
            <div className="border-t border-slate-200 dark:border-slate-700 p-4">
              <div className="flex items-center space-x-3">
                <div className="h-8 w-8 rounded-full bg-gradient-to-r from-blue-600 to-purple-600 flex items-center justify-center">
                  <span className="text-sm font-medium text-white">
                    {user?.name?.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-slate-900 dark:text-slate-100 truncate">
                    {user?.name}
                  </p>
                  <p className="text-xs text-slate-500 dark:text-slate-400 capitalize">
                    {user?.role}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  )
}
