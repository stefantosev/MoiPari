package com.example.backend.repository

import com.example.backend.model.Budget
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface BudgetRepository : JpaRepository<Budget, Int> {
}