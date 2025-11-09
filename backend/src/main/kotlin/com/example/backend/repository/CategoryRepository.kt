package com.example.backend.repository

import com.example.backend.model.Category
import com.example.backend.model.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CategoryRepository : JpaRepository<Category, Int> {
    fun findByUserId(userId: Int): List<Category>
}