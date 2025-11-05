package com.example.backend.service.impl

import com.example.backend.model.Budget
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.BudgetService
import org.springframework.stereotype.Service
import java.time.Month
import java.time.Year

@Service
class BudgetServiceImpl(
    private val budgetRepository: BudgetRepository,
    private val userRepository: UserRepository,
    private val expenseRepository: ExpenseRepository
) : BudgetService {

    private val exchangeRates = mapOf(
        "MKD_TO_EUR" to 0.016,
        "EUR_TO_MKD" to 61.5,
        "MKD_TO_USD" to 0.017,
        "USD_TO_MKD" to 58.5,
    )

    override fun createBudget(budget: Budget, userId: Int): Budget {
        val user = userRepository.findById(userId)
            .orElseThrow { Exception("User not found") }

        val newBudget = Budget(
            monthlyLimit = budget.monthlyLimit,
            year = budget.year,
            month = budget.month,
            user = user
        )
        return budgetRepository.save(newBudget)
    }

    override fun deleteBudget(id: Int) {
        budgetRepository.deleteById(id)
    }

    override fun updateBudget(id: Int, updateBudget: Budget): Budget? {
        budgetRepository.findById(id)
            .orElseThrow { Exception("Budget not found") }.let { existingBudget ->

            val updatedBudget = existingBudget.copy(
                monthlyLimit = updateBudget.monthlyLimit,
                year = updateBudget.year,
                month = updateBudget.month,
            )
            return budgetRepository.save(updatedBudget)
        }
    }

    override fun checkBudgetLimit(userId: Int, month: Int, year: Int): Boolean {
        val budgets = budgetRepository.findAll().filter {
            it.user?.id == userId && it.month == month && it.year == year
        }
        return budgets.sumOf { it.monthlyLimit.toDouble() } > 0
    }


    override fun getBudgetsByUser(userId: Int): List<Budget> {
        return budgetRepository.findAll().filter {
            it.user?.id == userId
        }
    }

    override fun convertCurrency(amount: Float, fromCurrency: String, toCurrency: String): Float {
        val key = "${fromCurrency}_TO_${toCurrency}".uppercase()
        val rate = exchangeRates[key] ?: throw Exception("Exchange rate not found for $fromCurrency to $toCurrency")
        return amount * rate.toFloat()
    }

    override fun getTotalBudget(userId: Int, month: Int, year: Int): Float {
        return budgetRepository.findAll()
            .filter { it.user?.id == userId && it.month == month && it.year == year }
            .sumOf { it.monthlyLimit.toDouble() }
            .toFloat()
    }

    override fun getRemainingBudget(userId: Int, month: Int, year: Int): Float {
        val totalBudget = getTotalBudget(userId, month, year)
        val totalExpenses = expenseRepository.findAll()
            .filter {
                it.user?.id == userId &&
                it.date.monthValue == month &&
                it.date.year == year
            }
            .sumOf { it.amount.toDouble() }
            .toFloat()

        return totalBudget - totalExpenses
    }

}