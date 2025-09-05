"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { LucideIcon } from "lucide-react"
import Link from "next/link"
import { cn } from "@/lib/utils"

interface ActionCardProps {
  title: string
  description: string
  icon: LucideIcon
  primaryAction: {
    label: string
    href: string
  }
  secondaryAction?: {
    label: string
    href: string
  }
  iconColor?: string
  gradient?: string
}

export function ActionCard({
  title,
  description,
  icon: Icon,
  primaryAction,
  secondaryAction,
  iconColor = "text-blue-600",
  gradient = "from-blue-500 to-purple-600"
}: ActionCardProps) {
  return (
    <Card className="group relative overflow-hidden bg-gradient-to-br from-white to-slate-50 dark:from-slate-800 dark:to-slate-900 border-slate-200 dark:border-slate-700 hover:shadow-2xl transition-all duration-500 hover:-translate-y-2">
      {/* Background gradient overlay */}
      <div className={cn(
        "absolute inset-0 bg-gradient-to-br opacity-0 group-hover:opacity-10 transition-opacity duration-500",
        gradient === "from-blue-500 to-purple-600" && "from-blue-500/20 to-purple-600/20",
        gradient === "from-green-500 to-emerald-600" && "from-green-500/20 to-emerald-600/20",
        gradient === "from-orange-500 to-red-600" && "from-orange-500/20 to-red-600/20",
        gradient === "from-purple-500 to-pink-600" && "from-purple-500/20 to-pink-600/20"
      )} />
      
      <CardHeader className="relative z-10">
        <div className="flex items-center space-x-3">
          <div className={cn(
            "p-3 rounded-xl bg-gradient-to-br transition-all duration-300 group-hover:scale-110",
            gradient === "from-blue-500 to-purple-600" && "from-blue-100 to-purple-100 dark:from-blue-900/50 dark:to-purple-900/50",
            gradient === "from-green-500 to-emerald-600" && "from-green-100 to-emerald-100 dark:from-green-900/50 dark:to-emerald-900/50",
            gradient === "from-orange-500 to-red-600" && "from-orange-100 to-red-100 dark:from-orange-900/50 dark:to-red-900/50",
            gradient === "from-purple-500 to-pink-600" && "from-purple-100 to-pink-100 dark:from-purple-900/50 dark:to-pink-900/50"
          )}>
            <Icon className={cn("h-6 w-6", iconColor)} />
          </div>
          <div>
            <CardTitle className="text-lg font-semibold text-slate-900 dark:text-slate-100">
              {title}
            </CardTitle>
            <CardDescription className="text-slate-600 dark:text-slate-400">
              {description}
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="relative z-10">
        <div className="space-y-3">
          <Link href={primaryAction.href}>
            <Button className={cn(
              "w-full transition-all duration-300 group-hover:shadow-lg",
              gradient === "from-blue-500 to-purple-600" && "bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700",
              gradient === "from-green-500 to-emerald-600" && "bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700",
              gradient === "from-orange-500 to-red-600" && "bg-gradient-to-r from-orange-600 to-red-600 hover:from-orange-700 hover:to-red-700",
              gradient === "from-purple-500 to-pink-600" && "bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
            )}>
              {primaryAction.label}
            </Button>
          </Link>
          
          {secondaryAction && (
            <Link href={secondaryAction.href}>
              <Button 
                variant="outline" 
                className="w-full border-slate-200 dark:border-slate-700 bg-transparent hover:bg-slate-50 dark:hover:bg-slate-800 transition-all duration-300"
              >
                {secondaryAction.label}
              </Button>
            </Link>
          )}
        </div>
      </CardContent>
      
      {/* Animated border */}
      <div className={cn(
        "absolute inset-0 rounded-lg border-2 border-transparent opacity-0 group-hover:opacity-30 transition-opacity duration-500",
        gradient === "from-blue-500 to-purple-600" && "bg-gradient-to-r from-blue-500 to-purple-500",
        gradient === "from-green-500 to-emerald-600" && "bg-gradient-to-r from-green-500 to-emerald-500",
        gradient === "from-orange-500 to-red-600" && "bg-gradient-to-r from-orange-500 to-red-500",
        gradient === "from-purple-500 to-pink-600" && "bg-gradient-to-r from-purple-500 to-pink-500"
      )} />
    </Card>
  )
}
