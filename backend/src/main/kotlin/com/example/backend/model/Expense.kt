package com.example.backend.model

import com.example.backend.model.Enums.PAYMENT
import com.fasterxml.jackson.annotation.JsonBackReference
import com.fasterxml.jackson.annotation.JsonIdentityInfo
import com.fasterxml.jackson.annotation.JsonManagedReference
import com.fasterxml.jackson.annotation.ObjectIdGenerators
import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "expenses")
//@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator::class, property = "id")
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

    @JsonManagedReference("expense-categories")
    val categories: MutableList<Category> = mutableListOf(),

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @JsonBackReference("user-expenses")
    var user: User? = null,
)