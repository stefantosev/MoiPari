package com.example.backend.service.impl

import com.example.backend.model.Budget
import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.BudgetService
import org.springframework.stereotype.Service

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

    override fun createBudget(request: BudgetRequest): BudgetResponse {
        val user = userRepository.findById(request.userId)
            .orElseThrow { Exception("User not found") }

        val newBudget = Budget(
            monthlyLimit = request.monthlyLimit,
            year = request.year,
            month = request.month,
            user = user
        )
        val savedBudget = budgetRepository.save(newBudget)
        return BudgetResponse.fromEntity(savedBudget)
    }

    override fun deleteBudget(id: Int) {
        budgetRepository.deleteById(id)
    }

    override fun updateBudget(id: Int, request: BudgetRequest): BudgetResponse {
        val existingBudget = budgetRepository.findById(id)
            .orElseThrow {
                Exception("Budget not found")
            }

        val user = userRepository.findById(request.userId)
            .orElseThrow {
                Exception("User not found")
            }

        val updatedBudget = existingBudget.copy(
            monthlyLimit = request.monthlyLimit,
            year = request.year,
            month = request.month,
            user = user
        )
        val savedBudget = budgetRepository.save(updatedBudget)
        return BudgetResponse.fromEntity(savedBudget)

    }

    override fun checkBudgetLimit(userId: Int, month: Int, year: Int): Boolean {
        val budgets = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)

        return budgets.sumOf { it.monthlyLimit.toDouble() } > 0
    }


    override fun getBudgetsByUser(userId: Int): List<BudgetResponse> {
        return budgetRepository.findByUserId(userId).map{
            BudgetResponse.fromEntity(it)
        }
    }

    override fun convertCurrency(amount: Float, fromCurrency: String, toCurrency: String): Float {
        val key = "${fromCurrency}_TO_${toCurrency}".uppercase()
        val rate = exchangeRates[key] ?: throw Exception("Exchange rate not found for $fromCurrency to $toCurrency")
        return amount * rate.toFloat()
    }

    override fun getTotalBudget(userId: Int, month: Int, year: Int): Float {
        return budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            .sumOf { it.monthlyLimit.toDouble() }
            .toFloat()
    }

//    override fun getRemainingBudget(userId: Int, month: Int, year: Int): Float {
//        val totalBudget = getTotalBudget(userId, month, year)
//        val totalExpenses = budg.findByUserIdAndMonthAndYear(userId, month, year)
//            .sumOf { it.amount.toDouble() }
//            .toFloat()
//
//        return totalBudget - totalExpenses
//    }

}