package com.example.backend.service.impl

import com.example.backend.model.Category
import com.example.backend.model.User
import com.example.backend.model.dto.CategoryRequest
import com.example.backend.model.dto.CategoryResponse
import com.example.backend.repository.CategoryRepository
import com.example.backend.repository.UserRepository
import com.example.backend.service.CategoryService
import org.springframework.stereotype.Service

@Service
class CategoryServiceImpl(
    private val categoryRepository: CategoryRepository,
    private val userRepository: UserRepository
) : CategoryService {

    override fun createCategory(request: CategoryRequest): CategoryResponse {
        val user = userRepository.findById(request.userId)
            .orElseThrow { Exception("User not found") }

        val category = Category(
            name = request.name,
            icon = request.icon,
            color = request.color,
            user = user
        )

        val savedCategory = categoryRepository.save(category)
        return CategoryResponse.fromEntity(savedCategory)
    }

    override fun deleteCategory(id: Int) {
        categoryRepository.deleteById(id)
    }

    override fun updateCategory(id: Int, request: CategoryRequest): CategoryResponse {
        val existingCategory = categoryRepository.findById(id)
            .orElseThrow { Exception("Category not found") }

        val user = userRepository.findById(request.userId)
            .orElseThrow { Exception("User not found") }

        val updatedCategory = existingCategory.copy(
            name = request.name,
            icon = request.icon,
            color = request.color,
            user = user
        )
        val savedCategory = categoryRepository.save(updatedCategory)
        return CategoryResponse.fromEntity(savedCategory)
    }

    override fun getCategories(): List<CategoryResponse> {
        return categoryRepository.findAll().map { CategoryResponse.fromEntity(it) }
    }

    override fun getCategoryById(id: Int): CategoryResponse {
        val category = categoryRepository.findById(id)
            .orElseThrow { Exception("Category not found") }
        return CategoryResponse.fromEntity(category)
    }

    override fun getCategoriesByUser(userId: Int): List<CategoryResponse> {
        return categoryRepository.findByUserId(userId).map { CategoryResponse.fromEntity(it) }
    }
}