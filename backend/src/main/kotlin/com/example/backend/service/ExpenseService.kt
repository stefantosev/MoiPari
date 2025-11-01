package com.example.backend.service

import com.example.backend.model.Expense
import org.hibernate.sql.Update

interface ExpenseService {
    fun createExpense(expense: Expense) : Expense
    fun deleteExpense(id:Int)
    fun updateExpense(id: Int, updateExpense: Expense) : Expense?
    fun getExpenseById(id: Int) : Expense
    fun getExpenses() : List<Expense>
}
