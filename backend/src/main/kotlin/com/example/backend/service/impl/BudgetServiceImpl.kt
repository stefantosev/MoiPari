package com.example.backend.service.impl

import com.example.backend.model.Budget
import com.example.backend.repository.BudgetRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.BudgetService
import org.springframework.stereotype.Service

@Service
class BudgetServiceImpl(
    private val budgetRepository: BudgetRepository,
    private val userRepository: UserRepository
) : BudgetService {
    override fun createBudget(budget: Budget, userId: Int): Budget {
        val user = userRepository.findById(userId)
            .orElseThrow { Exception("User not found") }

        val newBudget = Budget(
            monthlyLimit = budget.monthlyLimit,
            year = budget.year,
            month = budget.month,
            user = user
        )
        return budgetRepository.save(newBudget)
    }

    override fun deleteBudget(id: Int) {
        budgetRepository.deleteById(id)
    }

    override fun updateBudget(id: Int, updateBudget: Budget): Budget? {
        budgetRepository.findById(id)
            .orElseThrow { Exception("Budget not found") }.let { existingBudget ->

            val updatedBudget = existingBudget.copy(
                monthlyLimit = updateBudget.monthlyLimit,
                year = updateBudget.year,
                month = updateBudget.month,
            )
            return budgetRepository.save(updatedBudget)
        }
    }

    override fun checkBudgetLimit(userId: Int, month: Int, year: Int): Boolean {
        val budgets = budgetRepository.findAll().filter {
            it.user?.id == userId && it.month == month && it.year == year
        }
        return budgets.sumOf { it.monthlyLimit.toDouble() } > 0
    }


    override fun getBudgetsByUser(userId: Int): List<Budget> {
        return budgetRepository.findAll().filter {
            it.user?.id == userId
        }
    }

}