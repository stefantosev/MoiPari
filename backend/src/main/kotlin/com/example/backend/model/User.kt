package com.example.backend.model

import jakarta.persistence.*
import lombok.NoArgsConstructor
import java.time.LocalDateTime


@Entity
@Table( name = "users")
@NoArgsConstructor
data class User (

    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY)
    val id: Int=0,
    val email: String= "",
    val password: String = "",
    val name: String? = null,
    val currency: String = "MKD",
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @OneToMany(mappedBy = "user", cascade = [CascadeType.ALL], orphanRemoval = true)
    val categories: MutableList<Category> = mutableListOf(),

    @OneToMany(mappedBy = "user", cascade = [CascadeType.ALL], orphanRemoval = true)
    val expenses: MutableList<Expense> = mutableListOf(),

    @OneToOne(mappedBy = "user", cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    val budget: Budget? = null

)