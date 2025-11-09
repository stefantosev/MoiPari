package com.example.backend.controller

import com.example.backend.model.dto.CategoryRequest
import com.example.backend.model.dto.CategoryResponse
import com.example.backend.service.CategoryService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/categories")
class CategoryController(private val categoryService: CategoryService) {

    @PostMapping
    fun createCategory(@RequestBody request: CategoryRequest): ResponseEntity<CategoryResponse> {
        val createdCategory = categoryService.createCategory(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCategory)
    }

    @PutMapping("/{id}")
    fun updateCategory(
        @PathVariable id: Int,
        @RequestBody request: CategoryRequest
    ): ResponseEntity<CategoryResponse> {
        val updatedCategory = categoryService.updateCategory(id, request)
        return ResponseEntity.ok(updatedCategory)
    }

    @GetMapping
    fun getAllCategories(): ResponseEntity<List<CategoryResponse>> {
        val categories = categoryService.getCategories()
        return ResponseEntity.ok(categories)
    }

    @GetMapping("/{id}")
    fun getCategoryById(@PathVariable id: Int): ResponseEntity<CategoryResponse> {
        val category = categoryService.getCategoryById(id)
        return ResponseEntity.ok(category)
    }

    @GetMapping("/user/{userId}")
    fun getCategoriesByUser(@PathVariable userId: Int): ResponseEntity<List<CategoryResponse>> {
        val categories = categoryService.getCategoriesByUser(userId)
        return ResponseEntity.ok(categories)
    }

    @DeleteMapping("/{id}")
    fun deleteCategory(@PathVariable id: Int): ResponseEntity<Void> {
        categoryService.deleteCategory(id)
        return ResponseEntity.noContent().build()
    }
}