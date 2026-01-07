package com.example.backend.model.dto

import com.example.backend.model.Budget
import java.math.BigDecimal
import java.math.RoundingMode

data class BudgetRequest(
    val monthlyLimit: BigDecimal,
    val month: Int,
    val year: Int,

)
{
    init {
        require(month in 1..12) { "Month must be between 1 and 12" }
        require(year in 2001..2099) { "Year must be valid" }
        require(monthlyLimit >= BigDecimal.ZERO) { "Monthly limit cannot be negative" }
    }
}

data class BudgetResponse(
    val id: Int,
    val monthlyLimit: BigDecimal,
    val month: Int,
    val year: Int,
    val userId: Int,
    val spentAmount: BigDecimal = BigDecimal.ZERO,
    val remainingAmount: BigDecimal = BigDecimal.ZERO,
    val percentageUsed: BigDecimal = BigDecimal.ZERO,
    val isOverBudget: Boolean = false,
) {
    companion object {
        fun fromEntity(budget: Budget, spentAmount: BigDecimal): BudgetResponse {
            val remaining = budget.monthlyLimit.subtract(spentAmount)
            val percentage = if(budget.monthlyLimit > BigDecimal.ZERO){
                spentAmount.divide(budget.monthlyLimit, 4, RoundingMode.HALF_UP).multiply(BigDecimal(100))
            } else{
                BigDecimal.ZERO
            }
            return BudgetResponse(
                id = budget.id,
                monthlyLimit = budget.monthlyLimit,
                month = budget.month,
                year = budget.year,
                userId = budget.user.id ?: 0,
                spentAmount = spentAmount,
                remainingAmount = remaining,
                percentageUsed = percentage,
                isOverBudget = spentAmount > budget.monthlyLimit
            )
        }
    }
}