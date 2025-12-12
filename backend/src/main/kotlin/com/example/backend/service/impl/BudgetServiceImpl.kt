package com.example.backend.service.impl

import com.example.backend.model.Budget
import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.BudgetService
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class BudgetServiceImpl(
    private val budgetRepository: BudgetRepository,
    private val userRepository: UserRepository,
) : BudgetService {

    @Value("\${api.exchange-rate.key}")
    private lateinit var apiKey: String
    private val apiUrl = "https://v6.exchangerate-api.com/v6"

    override fun createBudget(request: BudgetRequest, userId: Int): BudgetResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { Exception("User not found") }

        val newBudget = Budget(
            monthlyLimit = request.monthlyLimit,
            year = request.year,
            month = request.month,
            user = user,
            remainingAmount = request.monthlyLimit
        )
        val savedBudget = budgetRepository.save(newBudget)
        return BudgetResponse.fromEntity(savedBudget)
    }

    override fun deleteBudget(id: Int, userId: Int) {
        val budget = budgetRepository.findByIdAndUserId(id, userId)
            ?: throw IllegalArgumentException("Budget not found or you don't have permission")
        budgetRepository.delete(budget)
    }

    override fun updateBudget(id: Int, request: BudgetRequest, userId: Int): BudgetResponse {
        val existingBudget = budgetRepository.findById(id)
            .orElseThrow {
                Exception("Budget not found")
            }

        val user = userRepository.findById(userId)
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
        val url = "$apiUrl/$apiKey/latest/$fromCurrency"
        val restTemplate = RestTemplate()
        val response = restTemplate.getForObject(url, Map::class.java)

        val rates = response?.get("conversion_rates") as? Map<String, Double>
            ?: throw Exception("Failed to fetch exchange rates")
        val rate  = rates[toCurrency] ?: throw Exception("Exchange rate not found for $fromCurrency to $toCurrency")

        return (amount * rate).toFloat()
    }

    override fun getTotalBudget(userId: Int, month: Int, year: Int): Float {
        return budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            .sumOf { it.monthlyLimit.toDouble() }
            .toFloat()
    }
}