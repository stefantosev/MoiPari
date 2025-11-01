package com.example.backend.service

import com.example.backend.model.Category
import com.example.backend.model.User
import org.springframework.stereotype.Service

@Service
interface CategoryService {
    fun createCategory(category: Category) : Category
    fun deleteCategory(id : Int)
    fun updateCategory(id: Int, updateCategory: Category) : Category?
    fun getCategories() : List<Category>
    fun getCategoryById(id : Int) : Category
}