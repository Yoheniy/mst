"use client"

import { Bell, Search, Settings } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { UserMenu } from "@/components/user-menu"
import { useAuth } from "@/components/auth-provider"

export function Header() {
  const { user } = useAuth()

  return (
    <header className="sticky top-0 z-30 w-full border-b border-slate-200 dark:border-slate-700 bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl">
      <div className="flex h-16 items-center justify-between px-6">
        {/* Left side */}
        <div className="flex items-center space-x-4">
          <div className="hidden md:block">
            <h1 className="text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Dashboard
            </h1>
          </div>
        </div>

        

        {/* Right side */}
        <div className="flex items-center space-x-4">
          

          {/* User menu */}
          <UserMenu />
        </div>
      </div>
    </header>
  )
}
