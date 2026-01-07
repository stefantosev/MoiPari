package com.example.backend.service

import com.example.backend.model.Budget
import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.service.impl.CategorySpending
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.time.Month
import java.time.Year

@Service
interface BudgetService {
    fun createBudget(request: BudgetRequest, userId: Int) : BudgetResponse
    fun deleteBudget(id : Int, userId: Int)
    fun updateBudget(id: Int, request: BudgetRequest, userId: Int) : BudgetResponse
    fun checkBudgetLimit(userId: Int, month: Int, year: Int) : Boolean
    fun getBudgetsByUser(userId: Int) : List<BudgetResponse>
//    fun getTotalBudget(userId: Int, month: Int, year: Int): Float
    fun getBudgetProgress(userId: Int, months: Int): List<BudgetResponse>
    fun getTotalSpent(userId: Int, month: Int, year: Int): BigDecimal
    fun getRemainingBudget(userId: Int, month: Int, year: Int): BigDecimal
    fun getBudgetWithAnalytics(userId: Int, month: Int, year: Int): BudgetResponse?
    fun getCurrentBudget(userId: Int): BudgetResponse
    fun getSuggestedBudget(userId: Int): BigDecimal
    fun getSpendingByCategory(userId: Int, month: Int, year: Int): List<CategorySpending>
//    fun getRemainingBudget(userId: Int, month: Int, year: Int): Float

}