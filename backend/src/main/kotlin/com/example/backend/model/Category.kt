package com.example.backend.model

import jakarta.persistence.*

@Entity
@Table(name="categories")
data class Category (

    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY)
    val id: Int=0,
    val name: String="",
    val icon: String="",
    val color: String="",

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="user_id")
    var user: User? = null,

    @ManyToMany(mappedBy = "categories")
    val expenses: MutableList<Expense> = mutableListOf()
)