package com.example.backend.repository

import com.example.backend.model.Expense
import jakarta.persistence.Id
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.math.BigDecimal
import java.time.Month

@Repository
interface ExpenseRepository : JpaRepository<Expense, Int> {
    fun findAllExpensesByCategoriesIdAndUserId(categoryId: Int, userId: Int): List<Expense>
    fun findAllExpensesByUserId(userId: Int): List<Expense>
    fun findByIdAndUserId(id: Int, userId: Int): Expense

    @Query("""
        SELECT COALESCE(SUM(e.amount), 0) 
        FROM Expense e 
        WHERE e.user.id = :userId 
        AND YEAR(e.date) = :year 
        AND MONTH(e.date) = :month
    """)
    fun calculateTotalSpentForMonth(
        @Param("userId") userId: Int,
        @Param("month") month: Int,
        @Param("year") year: Int
    ): BigDecimal?

    @Query("""
        SELECT c.id as categoryId, c.name as categoryName, 
               COALESCE(SUM(e.amount), 0) as total
        FROM Expense e 
        JOIN e.categories c
        WHERE e.user.id = :userId 
        AND YEAR(e.date) = :year 
        AND MONTH(e.date) = :month
        GROUP BY c.id, c.name
    """)
    fun getSpendingByCategoryForMonth(
        @Param("userId") userId: Int,
        @Param("month") month: Int,
        @Param("year") year: Int
    ): List<CategorySpendingResult>

    data class CategorySpendingResult(
        val categoryId: Int,
        val categoryName: String,
        val total: BigDecimal
    )

    @Query("""
    SELECT COALESCE(AVG(subquery.monthly_total), 0)
    FROM (
        SELECT YEAR(e.date) as y, MONTH(e.date) as m, 
               SUM(e.amount) as monthly_total
        FROM Expense e
        WHERE e.user.id = :userId
        AND (YEAR(e.date) > :startYear OR 
             (YEAR(e.date) = :startYear AND MONTH(e.date) >= :startMonth))
        AND (YEAR(e.date) < :endYear OR 
             (YEAR(e.date) = :endYear AND MONTH(e.date) <= :endMonth))
        GROUP BY YEAR(e.date), MONTH(e.date)
    ) subquery
""")
    fun calculateAverageMonthlySpending(
        @Param("userId") userId: Int,
        @Param("startMonth") startMonth: Int,
        @Param("startYear") startYear: Int,
        @Param("endMonth") endMonth: Int,
        @Param("endYear") endYear: Int
    ): BigDecimal?
}