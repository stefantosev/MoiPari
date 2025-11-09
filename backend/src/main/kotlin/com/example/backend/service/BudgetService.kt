package com.example.backend.service

import com.example.backend.model.Budget
import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import org.springframework.stereotype.Service
import java.time.Month
import java.time.Year

@Service
interface BudgetService {
    fun createBudget(request: BudgetRequest) : BudgetResponse
    fun deleteBudget(id : Int)
    fun updateBudget(id: Int, request: BudgetRequest) : BudgetResponse
    fun checkBudgetLimit(userId: Int, month: Int, year: Int) : Boolean
    fun getBudgetsByUser(userId: Int) : List<BudgetResponse>
    fun convertCurrency(amount: Float, fromCurrency: String, toCurrency: String): Float
    fun getTotalBudget(userId: Int, month: Int, year: Int): Float
//    fun getRemainingBudget(userId: Int, month: Int, year: Int): Float

}