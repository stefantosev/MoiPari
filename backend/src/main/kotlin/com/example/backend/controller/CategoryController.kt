package com.example.backend.controller

import com.example.backend.model.dto.CategoryRequest
import com.example.backend.model.dto.CategoryResponse
import com.example.backend.service.CategoryService
import com.example.backend.config.security.JwtTokenUtil
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/categories")
class CategoryController(
    private val categoryService: CategoryService,
    private val jwtTokenUtil: JwtTokenUtil
) {

    @PostMapping
    fun createCategory(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestBody request: CategoryRequest
    ): ResponseEntity<CategoryResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val createdCategory = categoryService.createCategory(request, userId)
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCategory)
    }

    @PutMapping("/{id}")
    fun updateCategory(
        @RequestHeader("Authorization") authorizationHeader: String,
        @PathVariable id: Int,
        @RequestBody request: CategoryRequest
    ): ResponseEntity<CategoryResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val updatedCategory = categoryService.updateCategory(id, request, userId)
        return ResponseEntity.ok(updatedCategory)
    }

    @GetMapping
    fun getAllCategories(
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<List<CategoryResponse>> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val categories = categoryService.getCategoriesByUser(userId)
        return ResponseEntity.ok(categories)
    }

    @GetMapping("/{id}")
    fun getCategoryById(
        @RequestHeader("Authorization") authorizationHeader: String,
        @PathVariable id: Int
    ): ResponseEntity<CategoryResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val category = categoryService.getCategoryByIdAndUser(id, userId)
        return ResponseEntity.ok(category)
    }
    
    @DeleteMapping("/{id}")
    fun deleteCategory(
        @RequestHeader("Authorization") authorizationHeader: String,
        @PathVariable id: Int
    ): ResponseEntity<Void> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        categoryService.deleteCategory(id, userId)
        return ResponseEntity.noContent().build()
    }

    private fun extractToken(authorizationHeader: String): String {
        return authorizationHeader.replace("Bearer ", "")
    }
}