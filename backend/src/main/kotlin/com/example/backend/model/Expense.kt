package com.example.backend.model

import com.example.backend.model.Enums.PAYMENT
import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "expenses")
data class Expense(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,
    val amount: Float = 0F,
    val description: String = "",
    val date: LocalDateTime = LocalDateTime.now(),
    val paymentMethod: PAYMENT = PAYMENT.CASH,

    @ManyToMany
    @JoinTable(
        name = "expense_category",
        joinColumns = [JoinColumn(name = "expense_id")],
        inverseJoinColumns = [JoinColumn(name = "category_id")]
    )
    val categories: MutableList<Category> = mutableListOf(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    var user: User? = null,
)