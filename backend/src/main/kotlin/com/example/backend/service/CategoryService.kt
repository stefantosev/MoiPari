package com.example.backend.service

import com.example.backend.model.Category
import com.example.backend.model.User
import com.example.backend.model.dto.CategoryRequest
import com.example.backend.model.dto.CategoryResponse
import org.springframework.stereotype.Service

@Service
interface CategoryService {
    fun createCategory(request: CategoryRequest, userId : Int) : CategoryResponse
    fun deleteCategory(id : Int, userId: Int)
    fun updateCategory(id: Int, request: CategoryRequest, userId: Int) : CategoryResponse?
    fun getCategories() : List<CategoryResponse>
    fun getCategoryById(id : Int) : CategoryResponse
    fun getCategoriesByUser(userId : Int) : List<CategoryResponse>
    fun getCategoryByIdAndUser(id: Int, userId: Int): CategoryResponse?


}