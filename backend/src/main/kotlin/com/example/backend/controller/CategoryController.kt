package com.example.backend.controller

import com.example.backend.model.Category
import com.example.backend.model.User
import com.example.backend.service.CategoryService
import com.example.backend.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.HttpStatusCode
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/categories")
class CategoryController(private val categoryService: CategoryService, private val userService: UserService) {

    @PostMapping
    fun createCategory(@RequestBody category: Category, @RequestBody id: Int): ResponseEntity<Category> {
        val user = userService.getUserById(id)
        val createCategory = categoryService.createCategory(category, user)
        return ResponseEntity.status(HttpStatus.CREATED).body(createCategory)
    }

    @PutMapping("/{id}")
    fun updateCategory(@PathVariable id: Int, @RequestBody category: Category): ResponseEntity<Category> {
        val updatedCategory = categoryService.updateCategory(id, category)
        return ResponseEntity.ok(updatedCategory!!)
    }

    @GetMapping
    fun getAllCategories(): ResponseEntity<List<Category>> {
        val categories = categoryService.getCategories()
        return ResponseEntity.ok(categories)
    }

    @GetMapping("/{id}")
    fun getCategoryById(@PathVariable id: Int): ResponseEntity<Category> {
        val category = categoryService.getCategoryById(id)
        return ResponseEntity.ok(category)
    }

    @DeleteMapping("/{id}")
    fun deleteCategory(@PathVariable id: Int): ResponseEntity<Void> {
        categoryService.deleteCategory(id)
        return ResponseEntity.noContent().build()
    }
}