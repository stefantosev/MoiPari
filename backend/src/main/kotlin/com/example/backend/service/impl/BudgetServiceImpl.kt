package com.example.backend.service.impl

import com.example.backend.model.Budget
import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.BudgetService
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.math.RoundingMode
import java.time.LocalDateTime

@Service
@Transactional
class BudgetServiceImpl(
    private val budgetRepository: BudgetRepository,
    private val userRepository: UserRepository,
    private val expenseRepository: ExpenseRepository
) : BudgetService {

    override fun createBudget(request: BudgetRequest, userId: Int): BudgetResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { Exception("User not found") }

        val existingBudget = budgetRepository.findByUserIdAndMonthAndYear(userId, request.month, request.year)
        if (existingBudget != null) {
            throw IllegalArgumentException("Budget already exists for ${request.month}/${request.year}. Use update instead.")
        }

        val newBudget = Budget(
            monthlyLimit = request.monthlyLimit,
            year = request.year,
            month = request.month,
            user = user
        )
        val savedBudget = budgetRepository.save(newBudget)

        val spentAmount = calculateSpentAmount(userId, request.month, request.year)

        return BudgetResponse.fromEntity(savedBudget, spentAmount)
    }

    override fun deleteBudget(id: Int, userId: Int) {
        val budget = budgetRepository.findByIdAndUserId(id, userId)
            ?: throw IllegalArgumentException("Budget not found or you don't have permission")
        budgetRepository.delete(budget)
    }

    override fun updateBudget(id: Int, request: BudgetRequest, userId: Int): BudgetResponse {
        val existingBudget = budgetRepository.findByIdAndUserId(id, userId)
            ?: throw IllegalArgumentException("Budget not found or you don't have permission")

        if (existingBudget.month != request.month || existingBudget.year != request.year) {
            val conflictingBudget = budgetRepository.findByUserIdAndMonthAndYear(
                userId, request.month, request.year
            )
            if (conflictingBudget != null && conflictingBudget.id != id) {
                throw IllegalArgumentException("Another budget already exists for ${request.month}/${request.year}")
            }
        }

        val updatedBudget = existingBudget.copy(
            monthlyLimit = request.monthlyLimit,
            year = request.year,
            month = request.month,
            updatedAt = LocalDateTime.now()
        )
        val savedBudget = budgetRepository.save(updatedBudget)

        val spentAmount = calculateSpentAmount(userId, request.month, request.year)

        return BudgetResponse.fromEntity(savedBudget, spentAmount)
    }

    override fun checkBudgetLimit(userId: Int, month: Int, year: Int): Boolean {
        val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            ?: return false

        val totalSpent = calculateSpentAmount(userId, month, year)
        return totalSpent > budget.monthlyLimit
    }

    override fun getBudgetsByUser(userId: Int): List<BudgetResponse> {
        val budgets = budgetRepository.findByUserId(userId)

        return budgets.map { budget ->
            val spentAmount = calculateSpentAmount(userId, budget.month, budget.year)
            BudgetResponse.fromEntity(budget, spentAmount)
        }.sortedWith(compareBy<BudgetResponse> { it.year }.thenBy { it.month }.reversed())
    }

    override fun getCurrentBudget(userId: Int): BudgetResponse {
        val now = LocalDateTime.now()
        val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, now.monthValue, now.year)
            ?: throw IllegalArgumentException("No budget set for current month")

        val spentAmount = calculateSpentAmount(userId, now.monthValue, now.year)
        return BudgetResponse.fromEntity(budget, spentAmount)
    }

    override fun getBudgetWithAnalytics(userId: Int, month: Int, year: Int): BudgetResponse? {
        val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            ?: return null

        val spentAmount = calculateSpentAmount(userId, month, year)
        return BudgetResponse.fromEntity(budget, spentAmount)
    }

    override fun getRemainingBudget(userId: Int, month: Int, year: Int): BigDecimal {
        val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            ?: return BigDecimal.ZERO

        val totalSpent = calculateSpentAmount(userId, month, year)
        val remaining = budget.monthlyLimit.subtract(totalSpent)

        return remaining.max(BigDecimal.ZERO)
    }

    override fun getTotalSpent(userId: Int, month: Int, year: Int): BigDecimal {
        return calculateSpentAmount(userId, month, year)
    }

    override fun getBudgetProgress(userId: Int, months: Int): List<BudgetResponse> {
        val now = LocalDateTime.now()
        val currentYear = now.year
        val currentMonth = now.monthValue

        val budgets = mutableListOf<BudgetResponse>()

        for (i in 0 until months) {
            var month = currentMonth - i
            var year = currentYear

            if (month < 1) {
                month += 12
                year -= 1
            }

            val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year)
            val spentAmount = calculateSpentAmount(userId, month, year)

            if (budget != null) {
                budgets.add(BudgetResponse.fromEntity(budget, spentAmount))
            } else {


            }
        }

        return budgets
    }

    private fun calculateSpentAmount(userId: Int, month: Int, year: Int): BigDecimal {
        return expenseRepository.calculateTotalSpentForMonth(userId, month, year)
            ?: BigDecimal.ZERO
    }

    override fun getSpendingByCategory(userId: Int, month: Int, year: Int): List<CategorySpending> {
        val categorySpendings = expenseRepository.getSpendingByCategoryForMonth(userId, month, year)
        val totalSpent = calculateSpentAmount(userId, month, year)

        return categorySpendings.map { result ->
            CategorySpending(
                categoryId = result.categoryId,
                categoryName = result.categoryName,
                spentAmount = result.total,

                percentage = if (result.total > BigDecimal.ZERO && totalSpent > BigDecimal.ZERO) {
                    result.total.divide(totalSpent, 4, RoundingMode.HALF_UP)
                        .multiply(BigDecimal(100))
                } else BigDecimal.ZERO
            )
        }
    }

    override fun getSuggestedBudget(userId: Int): BigDecimal {
        val now = LocalDateTime.now()
        val sixMonthsAgo = now.minusMonths(6)

        val averageSpending = expenseRepository.calculateAverageMonthlySpending(
            userId,
            sixMonthsAgo.monthValue, sixMonthsAgo.year,
            now.monthValue, now.year
        ) ?: BigDecimal(1000.00)

        return averageSpending.multiply(BigDecimal("0.9"))
            .setScale(2, RoundingMode.HALF_UP)
    }
}

data class CategorySpending(
    val categoryId: Int,
    val categoryName: String,
    val spentAmount: BigDecimal,
    val percentage: BigDecimal
)