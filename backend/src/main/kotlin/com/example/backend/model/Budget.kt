package com.example.backend.model

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "budgets")
data class Budget(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    @Column(name = "monthly_limit", nullable = false, precision = 10, scale = 2)
    val monthlyLimit: BigDecimal = BigDecimal.ZERO,

    @Column(name = "budget_month", nullable = false)
    val month: Int = 1,

    @Column(name = "budget_year", nullable = false)
    val year: Int = 2026,

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User = User(),

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
) {

    @PreUpdate
    fun preUpdate() {
        updatedAt = LocalDateTime.now()
    }
}