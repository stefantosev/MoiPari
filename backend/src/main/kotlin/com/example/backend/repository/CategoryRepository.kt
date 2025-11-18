package com.example.backend.repository

import com.example.backend.model.Category
import com.example.backend.model.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository

@Repository
interface CategoryRepository : JpaRepository<Category, Int> {
    @Query("SELECT c FROM Category c WHERE c.user.id = :userId")
    fun findByUserId(@Param("userId") userId: Int): List<Category>

    @Query("SELECT c FROM Category c WHERE c.id = :id AND c.user.id = :userId")
    fun findByIdAndUserId(@Param("id") id: Int, @Param("userId") userId: Int): Category?
}