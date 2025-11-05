package com.example.backend.service

import com.example.backend.model.Budget
import org.springframework.stereotype.Service
import java.time.Month
import java.time.Year

@Service
interface BudgetService {
    fun createBudget(budget: Budget, userId: Int) : Budget
    fun deleteBudget(id : Int)
    fun updateBudget(id: Int, updateBudget: Budget) : Budget?
    fun checkBudgetLimit(userId: Int, month: Int, year: Int) : Boolean
    fun getBudgetsByUser(userId: Int) : List<Budget>
    fun convertCurrency(amount: Float, fromCurrency: String, toCurrency: String): Float
    fun getTotalBudget(userId: Int, month: Int, year: Int): Float
    fun getRemainingBudget(userId: Int, month: Int, year: Int): Float

}