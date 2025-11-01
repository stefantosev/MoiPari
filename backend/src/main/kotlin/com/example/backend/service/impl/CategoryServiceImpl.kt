package com.example.backend.service.impl

import com.example.backend.model.Category
import com.example.backend.repository.CategoryRepository
import com.example.backend.service.CategoryService

class CategoryServiceImpl(private val categoryRepository: CategoryRepository) : CategoryService {

    override fun createCategory(category: Category): Category {
        return categoryRepository.save(
            Category(
                name = category.name,
                icon = category.icon,
                color = category.color,
            )
        )
    }

    override fun deleteCategory(id: Int) {
        return categoryRepository.deleteById(id)
    }

    override fun updateCategory(id: Int, updateCategory: Category): Category? {
        categoryRepository.findById(id)
            .orElseThrow { Exception("Category not found") }.let { existingCategory ->

            val updatedCategory = existingCategory.copy(
                name = updateCategory.name,
                icon = updateCategory.icon,
                color = updateCategory.color,
            )
            return categoryRepository.save(updatedCategory)
        }
    }

    override fun getCategories(): List<Category> {
        return categoryRepository.findAll()
    }

    override fun getCategoryById(id: Int): Category {
        return categoryRepository.findById(id)
            .orElseThrow { Exception("Category not found") }
    }

}