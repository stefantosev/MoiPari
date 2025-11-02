package com.example.backend.controller

import com.example.backend.model.Expense
import com.example.backend.service.ExpenseService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
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
    fun getAllExpenses(): ResponseEntity<List<Expense>> {
        return ResponseEntity.ok(expenseService.getExpenses())
    }

    @GetMapping("/{id}")
    fun getExpenseById(id: Int): ResponseEntity<Expense> {
        return ResponseEntity.ok(expenseService.getExpenseById(id))
    }

    @PostMapping
    fun createExpense(@RequestBody expense: Expense): ResponseEntity<Expense> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(expenseService.createExpense((expense)))
    }

    @PutMapping("/{id}")
    fun updateExpense(@PathVariable id: Int, @RequestBody expense: Expense): ResponseEntity<Expense> {
        return ResponseEntity.ok(expenseService.updateExpense(id, expense))
    }

    fun deleteExpense(@PathVariable id: Int): ResponseEntity<Void> {
        expenseService.deleteExpense(id)
        return ResponseEntity.noContent().build()
    }
}