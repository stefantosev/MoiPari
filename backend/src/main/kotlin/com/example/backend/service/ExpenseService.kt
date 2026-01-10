package com.example.backend.service

import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import org.hibernate.sql.Update
import org.springframework.data.domain.Page
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.time.LocalDateTime

@Service
interface ExpenseService {
    fun createExpense(request: ExpenseRequest, userId: Int): ExpenseResponse
    fun deleteExpense(id: Int, userId: Int)
    fun updateExpense(id: Int, request: ExpenseRequest, userId: Int): ExpenseResponse
    fun getExpenseById(id: Int): ExpenseResponse
    fun getExpenses(): List<ExpenseResponse>
    fun getExpensesByCategoryId(categoryId: Int, userId : Int): List<ExpenseResponse>
    fun getExpensesByUserId(userId: Int) : List<ExpenseResponse>
    fun getExpenseByIdAndUser(id: Int, userId: Int): ExpenseResponse
    fun getExpensesByDateRange(userId : Int, startDate : LocalDateTime, endDate : LocalDateTime) : List<ExpenseResponse>
    fun getExpensesByAmountRange(userId : Int, amountStart : Float, amountEnd : Float) : List<ExpenseResponse>
    fun getExpensesByPaymentMethod(userId: Int, paymentMethod : PAYMENT) : List<ExpenseResponse>
    fun getTotalSpentByMonth(userId: Int, month: Int, year: Int) : BigDecimal
    fun getAverageDailySpending(userId: Int, days : Int) : BigDecimal
    fun getTopExpenses(userId: Int, limit: Int): List<ExpenseResponse>
    fun getTotalSpentBetween(userId: Int, startDate: LocalDateTime, endDate: LocalDateTime): BigDecimal
    fun searchExpenses(userId: Int, query: String): List<ExpenseResponse>
    fun getExpensesPage(userId: Int, page: Int, size: Int): Page<ExpenseResponse>
}
