package com.example.backend.repository

import com.example.backend.model.Expense
import org.springframework.data.jpa.repository.JpaRepository

interface ExpenseRepository : JpaRepository<Expense, Int> {
}