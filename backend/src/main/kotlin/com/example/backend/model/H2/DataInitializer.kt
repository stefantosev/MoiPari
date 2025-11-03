package com.example.backend.model.H2

import com.example.backend.model.Budget
import com.example.backend.model.Category
import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import com.example.backend.model.User
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.CategoryRepository
import com.example.backend.repository.ExpenseRepository
import com.example.backend.repository.UserRepository
import jakarta.persistence.EntityManager
import jakarta.transaction.Transactional
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import java.time.LocalDateTime

@Component
class DataInitializer(
    private val userRepository: UserRepository,
    private val categoryRepository: CategoryRepository,
    private val expenseRepository: ExpenseRepository,
    private val budgetRepository: BudgetRepository,
    private val entityManager: EntityManager
) : CommandLineRunner {

    @Transactional
    override fun run(vararg args: String?) {

        if (userRepository.count() > 0) {
            println("Database already initialized, skipping...")
            return
        }

        // Save users
        val user1 = userRepository.save(User(name = "Alice"))
        val user2 = userRepository.save(User(name = "Bob"))

        // Reattach users to the persistence context
        val managedUser1 = entityManager.merge(user1)
        val managedUser2 = entityManager.merge(user2)

        val foodCategory = Category(name = "Food", color = "Red", icon = "🍔", user = managedUser1)
        val transportCategory = Category(name = "Transport", color = "Blue", icon = "🚗", user = managedUser1)
        val entertainmentCategory = Category(name = "Entertainment", color = "Green", icon = "🎬", user = managedUser2)
        categoryRepository.saveAll(listOf(foodCategory, transportCategory, entertainmentCategory))


        val expense1 = Expense(
            amount = 12.5F,
            description = "Lunch at cafe",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CASH,
            user = managedUser1,
            categories = mutableListOf(foodCategory)
        )

        val expense2 = Expense(
            amount = 50F,
            description = "Uber ride",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CARD,
            user = managedUser1,
            categories = mutableListOf(transportCategory)
        )

        val expense3 = Expense(
            amount = 20F,
            description = "Movie ticket",
            date = LocalDateTime.now(),
            paymentMethod = PAYMENT.CASH,
            user = managedUser2,
            categories = mutableListOf(entertainmentCategory)
        )

        expenseRepository.saveAll(listOf(expense1, expense2, expense3))


        val budget1 = Budget(monthlyLimit = 500F, year = 2024, month = 6, user = managedUser1)
        val budget2 = Budget(monthlyLimit = 300F, year = 2024, month = 6, user = managedUser2)
        val budget3 = Budget(monthlyLimit = 700F, year = 2024, month = 7, user = managedUser1)

        budgetRepository.saveAll(listOf(budget1, budget2, budget3))

        println("H2 database initialized with sample data!")
    }
}