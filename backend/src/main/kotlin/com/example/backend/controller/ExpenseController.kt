package com.example.backend.controller

import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import com.example.backend.service.ExpenseService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/expenses")
class ExpenseController(private val expenseService: ExpenseService) {

    @GetMapping
    fun getAllExpenses(): ResponseEntity<List<ExpenseResponse>> {
        return ResponseEntity.ok(expenseService.getExpenses())
    }

    @GetMapping("/{id}")
    fun getExpenseById(@PathVariable id: Int): ResponseEntity<ExpenseResponse> {
        return ResponseEntity.ok(expenseService.getExpenseById(id))
    }

    @PostMapping
    fun createExpense(@RequestBody expense: ExpenseRequest): ResponseEntity<ExpenseResponse> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(expenseService.createExpense((expense)))
    }

    @PutMapping("/{id}")
    fun updateExpense(@PathVariable id: Int, @RequestBody expense: ExpenseRequest): ResponseEntity<ExpenseResponse> {
        return ResponseEntity.ok(expenseService.updateExpense(id, expense))
    }


    @DeleteMapping("/{id}")
    fun deleteExpense(@PathVariable id: Int): ResponseEntity<Void> {
        expenseService.deleteExpense(id)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/category/{categoryId}")
    fun getExpensesByCategoryId(@PathVariable categoryId: Int): ResponseEntity<List<ExpenseResponse>> {
        val expenses = expenseService.getExpensesByCategoryId(categoryId)
        return ResponseEntity.ok(expenses)
    }
}