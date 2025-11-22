package com.example.backend.service.impl

import com.example.backend.model.Expense
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import com.example.backend.repository.CategoryRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.ExpenseService
import org.springframework.stereotype.Service

@Service
class ExpenseServiceImpl(private val expenseRepository: ExpenseRepository, private val userRepository: UserRepository, private val categoryRepository: CategoryRepository) : ExpenseService {

    override fun createExpense(request: ExpenseRequest, userId: Int): ExpenseResponse {
        val user = userRepository.findById(userId)
            .orElseThrow{
                Exception("User not found")
            }
        // todo fix temp for now xdd
        val categories = categoryRepository.findAll()

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
            .orElseThrow(){
                Exception("Expense not found")
            }
        val user = userRepository.findById(userId)
            .orElseThrow(){
                Exception("User not found")
            }

        // todo temp for now fix later...
        val categories = categoryRepository.findAll()


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
            .orElseThrow(){
                Exception("Expense not found")
            }
        return ExpenseResponse.fromEntity(expense);
    }

    override fun getExpenses(): List<ExpenseResponse> {
        return expenseRepository.findAll().map {ExpenseResponse.fromEntity(it)}
    }

    override fun getExpensesByCategoryId(categoryId: Int): List<ExpenseResponse> {
        return expenseRepository.findAllByCategoriesId(categoryId).map {ExpenseResponse.fromEntity(it)}
    }

    override fun getExpensesByUserId(userId: Int): List<ExpenseResponse> {
        return expenseRepository.findAllExpensesByUserId(userId).map {ExpenseResponse.fromEntity(it) }
    }

    override fun getExpenseByIdAndUser(id: Int, userId: Int): ExpenseResponse {
        return ExpenseResponse.fromEntity(expenseRepository.findByIdAndUserId(id, userId));
    }

}