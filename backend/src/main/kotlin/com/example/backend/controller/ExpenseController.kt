package com.example.backend.controller

import com.example.backend.config.security.JwtTokenUtil
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import com.example.backend.service.ExpenseService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/expenses")
class ExpenseController(private val expenseService: ExpenseService, private val jwtTokenUtil: JwtTokenUtil) {

    @GetMapping
    fun getAllExpenses(@RequestHeader("Authorization") authorizationHeader: String): ResponseEntity<List<ExpenseResponse>> {

        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val expenses = expenseService.getExpensesByUserId(userId)

        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/{id}")
    fun getExpenseById(
        @RequestHeader("Authorization") authorizationHeader: String,
        @PathVariable id: Int
    ): ResponseEntity<ExpenseResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val expense = expenseService.getExpenseByIdAndUser(id, userId)

        return ResponseEntity.ok(expense)
    }

    @PostMapping
    fun createExpense(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestBody expense: ExpenseRequest
    ): ResponseEntity<ExpenseResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt();

        val createdExpense = expenseService.createExpense(expense, userId);

        return ResponseEntity.status(HttpStatus.CREATED)
            .body(createdExpense)
    }

    @PutMapping("/{id}")
    fun updateExpense(@RequestHeader("Authorization") authorizationHeader: String, @PathVariable id: Int, @RequestBody expense: ExpenseRequest): ResponseEntity<ExpenseResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt();

        val updatedExpense = expenseService.updateExpense(id, expense, userId)
        return ResponseEntity.ok(updatedExpense)
    }


    @DeleteMapping("/{id}")
    fun deleteExpense(@RequestHeader("Authorization") authorizationHeader: String, @PathVariable id: Int): ResponseEntity<Void> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        expenseService.deleteExpense(id,userId)

        return ResponseEntity.noContent().build()
    }

    @GetMapping("/category/{categoryId}")
    fun getExpensesByCategoryId(@PathVariable categoryId: Int): ResponseEntity<List<ExpenseResponse>> {
        val expenses = expenseService.getExpensesByCategoryId(categoryId)
        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/user/{userId}")
    fun getExpensesByUserId(@PathVariable userId: Int): ResponseEntity<List<ExpenseResponse>> {
        val expenses = expenseService.getExpensesByUserId(userId)
        return ResponseEntity.ok(expenses)
    }

    private fun extractToken(authorizationHeader: String): String {
        return authorizationHeader.replace("Bearer ", "")
    }

}