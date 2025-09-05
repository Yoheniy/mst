"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { LucideIcon } from "lucide-react"
import { cn } from "@/lib/utils"

interface StatCardProps {
  title: string
  value: string | number
  change?: number
  changeLabel?: string
  icon: LucideIcon
  iconColor?: string
  trend?: "up" | "down" | "neutral"
  loading?: boolean
}

export function StatCard({
  title,
  value,
  change,
  changeLabel,
  icon: Icon,
  iconColor = "text-blue-600",
  trend = "neutral",
  loading = false
}: StatCardProps) {
  const getTrendColor = () => {
    switch (trend) {
      case "up":
        return "text-green-600 dark:text-green-400"
      case "down":
        return "text-red-600 dark:text-red-400"
      default:
        return "text-slate-600 dark:text-slate-400"
    }
  }

  const getTrendIcon = () => {
    switch (trend) {
      case "up":
        return "↗"
      case "down":
        return "↘"
      default:
        return "→"
    }
  }

  return (
    <Card className="group relative overflow-hidden bg-gradient-to-br from-white to-slate-50 dark:from-slate-800 dark:to-slate-900 border-slate-200 dark:border-slate-700 hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
      {/* Background gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50/50 to-purple-50/50 dark:from-blue-900/20 dark:to-purple-900/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
      
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2 relative z-10">
        <CardTitle className="text-sm font-medium text-slate-600 dark:text-slate-400">
          {title}
        </CardTitle>
        <div className={cn(
          "p-2 rounded-lg bg-gradient-to-br from-blue-100 to-purple-100 dark:from-blue-900/50 dark:to-purple-900/50",
          "group-hover:scale-110 transition-transform duration-300"
        )}>
          <Icon className={cn("h-4 w-4", iconColor)} />
        </div>
      </CardHeader>
      <CardContent className="relative z-10">
        <div className="text-2xl font-bold text-slate-900 dark:text-slate-100 mb-1">
          {loading ? (
            <div className="h-8 w-20 bg-slate-200 dark:bg-slate-700 rounded animate-pulse" />
          ) : (
            typeof value === "number" ? value.toLocaleString() : value
          )}
        </div>
        {change !== undefined && (
          <div className="flex items-center space-x-1">
            <span className={cn("text-xs font-medium", getTrendColor())}>
              {getTrendIcon()} {change > 0 ? "+" : ""}{change}%
            </span>
            {changeLabel && (
              <span className="text-xs text-slate-500 dark:text-slate-400">
                {changeLabel}
              </span>
            )}
          </div>
        )}
      </CardContent>
      
      {/* Animated border */}
      <div className="absolute inset-0 rounded-lg border-2 border-transparent bg-gradient-to-r from-blue-500 to-purple-500 opacity-0 group-hover:opacity-20 transition-opacity duration-300" />
    </Card>
  )
}
