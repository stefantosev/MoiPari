package com.example.backend.service

import com.example.backend.model.Expense
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import org.hibernate.sql.Update
import org.springframework.stereotype.Service

@Service
interface ExpenseService {
    fun createExpense(request: ExpenseRequest): ExpenseResponse
    fun deleteExpense(id: Int)
    fun updateExpense(id: Int, request: ExpenseRequest): ExpenseResponse
    fun getExpenseById(id: Int): ExpenseResponse
    fun getExpenses(): List<ExpenseResponse>
    fun getExpensesByCategoryId(categoryId: Int): List<ExpenseResponse>
    fun getExpensesByUserId(userId: Int) : List<ExpenseResponse>
    fun getExpenseByIdAndUser(id: Int, userId: Int): ExpenseResponse
}
