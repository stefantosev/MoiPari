package com.example.backend.service.impl

import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import com.example.backend.repository.ExpenseRepository
import com.example.backend.service.ExpenseService
import org.springframework.stereotype.Service
import java.time.LocalDateTime

@Service
class ExpenseServiceImpl (private val expenseRepository: ExpenseRepository) : ExpenseService {

    override fun createExpense(expense: Expense): Expense {
        return expenseRepository.save(
            Expense(
                amount = expense.amount,
                description = expense.description,
                date = expense.date,
                paymentMethod = expense.paymentMethod,
                categories = expense.categories,
                user = expense.user
            )
        )
    }

    override fun deleteExpense(id: Int) {
        expenseRepository.deleteById(id)
    }

    override fun updateExpense(id: Int, updateExpense: Expense): Expense? {
        expenseRepository.findById(id)
            .orElseThrow { Exception("Expense not found") }.let { existingExpense ->

            val updatedExpense = existingExpense.copy(
                amount = updateExpense.amount,
                description = updateExpense.description,
                date = updateExpense.date,
                paymentMethod = updateExpense.paymentMethod,
                categories = updateExpense.categories,
            )
            return expenseRepository.save(updatedExpense)
        }
    }

    override fun getExpenseById(id: Int): Expense {
        return expenseRepository.findById(id)
            .orElseThrow { Exception("Expense not found") }
    }

    override fun getExpenses(): List<Expense> {
        return expenseRepository.findAll()
    }


}