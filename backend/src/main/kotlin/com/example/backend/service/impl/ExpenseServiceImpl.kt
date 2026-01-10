package com.example.backend.service.impl

import com.example.backend.exceptions.BudgetExceededException
import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.CategoryRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.ExpenseService
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.math.RoundingMode
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

@Service
class ExpenseServiceImpl(private val expenseRepository: ExpenseRepository, private val userRepository: UserRepository, private val categoryRepository: CategoryRepository, private val budgetRepository: BudgetRepository) : ExpenseService {

    private fun checkBudgetLimit(userId: Int, expenseAmount: Float, expenseDate: LocalDateTime){
        val month = expenseDate.monthValue
        val year = expenseDate.year

        val budget = budgetRepository.findByUserIdAndMonthAndYear(userId, month, year) ?: return

        val currentSpent = expenseRepository.calculateTotalSpentForMonth(userId,month, year) ?: BigDecimal.ZERO

        val newExpenseAmount = BigDecimal.valueOf(expenseAmount.toDouble())

        val newTotal = currentSpent+ newExpenseAmount

        if (newTotal > budget.monthlyLimit){
            val remaining = budget.monthlyLimit - currentSpent
            throw BudgetExceededException(
                "Cannot add expense: Would exceed monthly budget of ${budget.monthlyLimit}. " + "Remaining: ${remaining.setScale(2)}." + "Expense amount: ${newExpenseAmount.setScale(2)}"
            )
        }
    }
    override fun createExpense(request: ExpenseRequest, userId: Int): ExpenseResponse {
        val user = userRepository.findById(userId)
            .orElseThrow{
                Exception("User not found")
            }

        checkBudgetLimit(userId, request.amount, request.date)

        val categories = categoryRepository.findAllCategoriesByIdAndUserId(request.categoryIds, userId)

        if (categories.isEmpty() || (categories.size != request.categoryIds.size)) {
            throw Exception("Categories are empty or some categories not found or don't belong to user")
        }
        val expense = Expense(
            amount = request.amount,
            description = request.description,
            date = request.date,
            paymentMethod = request.paymentMethod,
            categories = categories.toMutableList(),
            user = user
        )

        val savedExpense = expenseRepository.save(expense)
        return ExpenseResponse.fromEntity(savedExpense)

    }

    override fun deleteExpense(id: Int, userId: Int) {
        val expense = expenseRepository.findByIdAndUserId(id, userId)

        expenseRepository.delete(expense)
    }

    override fun updateExpense(id: Int, request: ExpenseRequest, userId: Int): ExpenseResponse {
        val existingExpense = expenseRepository.findById(id)
            .orElseThrow{
                Exception("Expense not found")
            }
        val user = userRepository.findById(userId)
            .orElseThrow{
                Exception("User not found")
            }

        checkBudgetLimit(userId, request.amount, request.date)

        val categories = categoryRepository.findAllCategoriesByIdAndUserId(request.categoryIds, userId)

        if (categories.isEmpty() || (categories.size != request.categoryIds.size)) {
            throw Exception("Categories are empty or some categories not found or don't belong to user")
        }


        val updatedExpense = existingExpense.copy(
            amount = request.amount,
            description = request.description,
            date = request.date,
            paymentMethod = request.paymentMethod,
            categories = categories.toMutableList(),
            user = user
        )
        val savedExpense = expenseRepository.save(updatedExpense)
        return ExpenseResponse.fromEntity(savedExpense)
    }

    override fun getExpenseById(id: Int): ExpenseResponse {
        val expense = expenseRepository.findById(id)
            .orElseThrow{
                Exception("Expense not found")
            }
        return ExpenseResponse.fromEntity(expense)
    }

    override fun getExpenses(): List<ExpenseResponse> {
        return expenseRepository.findAll().map {ExpenseResponse.fromEntity(it)}
    }

    override fun getExpensesByCategoryId(categoryId: Int, userId: Int): List<ExpenseResponse> {
        return expenseRepository.findAllExpensesByCategoriesIdAndUserId(categoryId, userId).map {ExpenseResponse.fromEntity(it)}
    }

    override fun getExpensesByUserId(userId: Int): List<ExpenseResponse> {
        return expenseRepository.findAllExpensesByUserId(userId).map {ExpenseResponse.fromEntity(it) }
    }

    override fun getExpenseByIdAndUser(id: Int, userId: Int): ExpenseResponse {
        return ExpenseResponse.fromEntity(expenseRepository.findByIdAndUserId(id, userId))
    }

    override fun getExpensesByDateRange(
        userId: Int,
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): List<ExpenseResponse> {
        return expenseRepository.findByUserIdAndDateBetween(userId, startDate, endDate).map { ExpenseResponse.fromEntity(it) }
    }

    override fun getExpensesByAmountRange(userId: Int, amountStart: Float, amountEnd: Float): List<ExpenseResponse> {

        require(amountStart >= 0) { "Minimum amount cannot be negative" }
        require(amountEnd >= amountStart) { "Maximum amount must be greater than or equal to minimum amount" }

        return expenseRepository.findByUserIdAndAmountBetween(userId, amountStart, amountEnd).map {ExpenseResponse.fromEntity(it)}
    }

    override fun getExpensesByPaymentMethod(userId: Int, paymentMethod: PAYMENT): List<ExpenseResponse> {
        return expenseRepository.findByUserIdAndPaymentMethod(userId, paymentMethod).map {ExpenseResponse.fromEntity(it)}
    }

    override fun getTotalSpentByMonth(userId: Int, month: Int, year: Int): BigDecimal {
        return expenseRepository.calculateTotalSpentForMonth(userId, month, year) ?: BigDecimal.ZERO
    }

    override fun getAverageDailySpending(userId: Int, days: Int): BigDecimal {
        val endDate = LocalDateTime.now()
        val startDate = endDate.minusDays(days.toLong())

        val total = expenseRepository.calculateTotalSpentBetween(userId, startDate, endDate) ?: BigDecimal.ZERO

        return total.divide(BigDecimal(days), 2, RoundingMode.HALF_UP)
    }

    override fun getTopExpenses(userId: Int, limit: Int): List<ExpenseResponse> {
        val expenses = expenseRepository.findAllExpensesByUserId(userId)
            .sortedByDescending { it.amount }
            .take(limit)

        return expenses.map { ExpenseResponse.fromEntity(it) }
    }

    private fun validateDateRange(startDate: LocalDateTime, endDate: LocalDateTime){
        require(!startDate.isAfter(endDate)){"Start date cannot be after end date"}

        val maxDays = 365
        val daysBetween = ChronoUnit.DAYS.between(startDate, endDate)
        require(daysBetween <= maxDays) {"Date range cannot exceed $maxDays days"}
    }

    override fun getTotalSpentBetween(
        userId: Int,
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): BigDecimal {
        validateDateRange(startDate, endDate)

        return expenseRepository.calculateTotalSpentBetween(userId, startDate, endDate)
            ?: BigDecimal.ZERO
    }

    override fun searchExpenses(userId: Int, query: String): List<ExpenseResponse> {
        require(query.isNotBlank()) {"Search query cannot be empty"}
        require(query.length >=2) {"Search query must be at least 2 characters" }

        val expenses = expenseRepository.searchByUserIdAndDescription(userId, query)

        return expenses.map { ExpenseResponse.fromEntity(it) }
    }

    override fun getExpensesPage(userId: Int, page: Int, size: Int): Page<ExpenseResponse> {
        require(page >= 0) { "Page number cannot be negative" }
        require(size > 0) { "Page size must be greater than 0" }
        require(size <= 100) { "Page size cannot exceed 100" }

        val pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "date"))
        val expensesPage = expenseRepository.findAllByUserId(userId, pageable)

        return expensesPage.map { ExpenseResponse.fromEntity(it) }
    }

}