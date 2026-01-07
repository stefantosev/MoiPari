package com.example.backend.repository

import com.example.backend.model.Budget
import com.example.backend.model.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface BudgetRepository : JpaRepository<Budget, Int> {
    fun findByUserIdAndMonthAndYear(userId: Int, month : Int, year :Int) : Budget?
    fun findByIdAndUserId(id: Int, userId: Int): Budget?
    fun findByUserId(userId: Int) : List<Budget>
}