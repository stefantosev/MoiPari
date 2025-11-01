package com.example.backend.controller

import com.example.backend.model.Category
import com.example.backend.service.CategoryService
import org.springframework.http.HttpStatus
import org.springframework.http.HttpStatusCode
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/categories")
class CategoryController(private val categoryService: CategoryService) {

    @PostMapping
    fun createCategory(@RequestBody category: Category) : ResponseEntity<Category> {
        val createCategory = categoryService.createCategory(category)
        return ResponseEntity.status(HttpStatus.CREATED).body(createCategory)
    }

    @PostMapping("/{id}")
    fun updateCategory(@PathVariable id: Int, @RequestBody category: Category) : ResponseEntity<Category> {
        val updatedCategory = categoryService.updateCategory(id, category)
        return ResponseEntity.ok(updatedCategory!!)
    }

    @GetMapping
    fun getAllCategories() : ResponseEntity<List<Category>> {
        val categories = categoryService.getCategories()
        return ResponseEntity.ok(categories)
    }

    @GetMapping("/{id}")
    fun getCategoryById(@PathVariable id: Int) : ResponseEntity<Category> {
        val category = categoryService.getCategoryById(id)
        return ResponseEntity.ok(category)
    }

    @DeleteMapping("/{id}")
    fun deleteCategory(@PathVariable id: Int) : ResponseEntity<String> {
        categoryService.deleteCategory(id)
        return ResponseEntity(HttpStatusCode.valueOf(204))
    }
}