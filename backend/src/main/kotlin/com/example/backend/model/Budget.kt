package com.example.backend.model

import jakarta.persistence.*


@Entity
@Table(name="budget")
data class Budget (
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY)
    val id: Int=0,

    val monthlyLimit: Float=0F,

    @Column(name = "budget_month")
    val month: Int=0,

    @Column(name = "budget_year")
    val year: Int=0,


    @OneToOne(cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    var user: User? = null,
)