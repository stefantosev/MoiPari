package com.example.backend.repository

import com.example.backend.model.Expense
import jakarta.persistence.Id
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.time.Month

@Repository
interface ExpenseRepository : JpaRepository<Expense, Int> {
}