package com.example.backend.repository

import com.example.backend.model.Category
import com.example.backend.model.User
import org.springframework.data.jpa.repository.JpaRepository

interface CategoryRepository : JpaRepository<Category, Int> {
}