package com.example.backend.repository

import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.Expense
import jakarta.persistence.Id
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.math.BigDecimal
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.Month

@Repository
interface ExpenseRepository : JpaRepository<Expense, Int> {
    fun findAllExpensesByCategoriesIdAndUserId(categoryId: Int, userId: Int): List<Expense>
    fun findAllExpensesByUserId(userId: Int): List<Expense>
    fun findByIdAndUserId(id: Int, userId: Int): Expense

    @Query(
        """
        SELECT COALESCE(SUM(e.amount), 0) 
        FROM Expense e 
        WHERE e.user.id = :userId 
        AND YEAR(e.date) = :year 
        AND MONTH(e.date) = :month
    """
    )
    fun calculateTotalSpentForMonth(
        @Param("userId") userId: Int,
        @Param("month") month: Int,
        @Param("year") year: Int
    ): BigDecimal?

    @Query(
        """
        SELECT c.id as categoryId, c.name as categoryName, 
               COALESCE(SUM(e.amount), 0) as total
        FROM Expense e 
        JOIN e.categories c
        WHERE e.user.id = :userId 
        AND YEAR(e.date) = :year 
        AND MONTH(e.date) = :month
        GROUP BY c.id, c.name
    """
    )
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

    @Query(
        """
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
"""
    )
    fun calculateAverageMonthlySpending(
        @Param("userId") userId: Int,
        @Param("startMonth") startMonth: Int,
        @Param("startYear") startYear: Int,
        @Param("endMonth") endMonth: Int,
        @Param("endYear") endYear: Int
    ): BigDecimal?

    @Query(
        """
            select e from Expense e
            where e.user.id = :userId
            and e.date >= :startDate
            and e.date <= :endDate
            order by e.date desc
        """
    )
    fun findByUserIdAndDateBetween(
        @Param("userId") userId: Int,
        @Param("startDate") startDate: LocalDateTime,
        @Param("endDate") endDate: LocalDateTime
    ): List<Expense>

    @Query(
        """
            select e from Expense e
            where e.user.id = :userId
            and e.amount >= :minAmount
            and e.amount <= :maxAmount
            order by e.amount desc
        """
    )
    fun findByUserIdAndAmountBetween(
        @Param("userId") userId: Int,
        @Param("minAmount") minAmount: Float,
        @Param("maxAmount") maxAmount: Float
    ): List<Expense>

    @Query(
        """
            select e from Expense e
            where e.user.id = :userId
            and e.paymentMethod = :paymentMethod
            order by e.amount desc 
        """
    )
    fun findByUserIdAndPaymentMethod(
        @Param("userId") userId: Int,
        @Param("paymentMethod") paymentMethod: PAYMENT,
    ): List<Expense>

    @Query(
        """
            select e from Expense e
            where e.user.id = :userId
            and lower(e.description) like lower(concat('%', :query, '%'))
             order by e.date desc
        """
    )
    fun searchByUserIdAndDescription(
        @Param("userId") userId: Int,
        @Param("query") query: String
    ): List<Expense>

    @Query(
        """
            select coalesce(sum(e.amount), 0)
             from Expense e
             where e.user.id = :userId
             and e.date >= :startDate
             and e.date <= :endDate
        """
    )
    fun calculateTotalSpentBetween(
        @Param("userId") userId: Int,
        @Param("startDate") startDate: LocalDateTime,
        @Param("endDate") endDate: LocalDateTime
    ): BigDecimal?

    fun findAllByUserId(userId: Int, pageable: Pageable): Page<Expense>
}