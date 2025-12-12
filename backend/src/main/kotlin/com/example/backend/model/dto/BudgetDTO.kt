package com.example.backend.model.dto

import com.example.backend.model.Budget

data class BudgetRequest(
    val monthlyLimit: Float,
    val month: Int,
    val year: Int,
    val userId: Int,
    var remainingAmount:  Float = 0F
)

data class BudgetResponse(
    val id: Int,
    val monthlyLimit: Float,
    val month: Int,
    val year: Int,
    val userId: Int,
    var remainingAmount:  Float = 0F
) {
    companion object {
        fun fromEntity(budget: Budget): BudgetResponse {
            return BudgetResponse(
                id = budget.id,
                monthlyLimit = budget.monthlyLimit,
                month = budget.month,
                year = budget.year,
                userId = budget.user?.id ?: 0,
                remainingAmount = budget.remainingAmount
            )
        }
    }
}