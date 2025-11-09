package com.example.backend.model.dto

import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import java.time.LocalDateTime

data class ExpenseRequest(
    val amount: Float,
    val description: String,
    val date: LocalDateTime,
    val paymentMethod: PAYMENT = PAYMENT.CASH,
    val categoryIds: List<Int>,
    val userId: Int
)

data class ExpenseResponse(
    val id: Int,
    val amount: Float,
    val description: String,
    val date: LocalDateTime,
    val paymentMethod: PAYMENT,
    val categoryIds: List<Int>,
    val userId : Int
){
    companion object{
        fun fromEntity(expense: Expense): ExpenseResponse{
            return ExpenseResponse(
                id = expense.id,
                amount = expense.amount,
                description = expense.description,
                date = expense.date,
                paymentMethod = expense.paymentMethod,
                categoryIds = expense.categories.map { it.id },
                userId = expense.user?.id ?:0
            )
        }
    }
}
