package com.example.backend.model.H2

import com.example.backend.model.Category
import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import com.example.backend.model.User
import com.example.backend.repository.CategoryRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import java.time.LocalDateTime

@Component
class DataInitializer(
    private val userRepository: UserRepository,
    private val categoryRepository: CategoryRepository,
    private val expenseRepository: ExpenseRepository
) : CommandLineRunner {

    override fun run(vararg args: String?) {

        if (userRepository.count() > 0) {
            println("Database already initialized, skipping...")
            return
        }

        val user1 = User(name = "Alice")
        val user2 = User(name = "Bob")
        userRepository.saveAll(listOf(user1, user2))

        val foodCategory = Category(name = "Food", color = "Red", icon = "🍔", user = user1)
        val transportCategory = Category(name = "Transport", color = "Blue", icon = "🚗", user = user1)
        val entertainmentCategory = Category(name = "Entertainment", color = "Green", icon = "🎬", user = user2)
        categoryRepository.saveAll(listOf(foodCategory, transportCategory, entertainmentCategory))

        val expense1 = Expense(
            amount = 12.5F,
            description = "Lunch at cafe",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CASH,
            user = user1,
            categories = mutableListOf(foodCategory)
        )

        val expense2 = Expense(
            amount = 50F,
            description = "Uber ride",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CARD,
            user = user1,
            categories = mutableListOf(transportCategory)
        )

        val expense3 = Expense(
            amount = 20F,
            description = "Movie ticket",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CASH,
            user = user2,
            categories = mutableListOf(entertainmentCategory)
        )

        expenseRepository.saveAll(listOf(expense1, expense2, expense3))

        println("H2 database initialized with sample data!")
    }
}