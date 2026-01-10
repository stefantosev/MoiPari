package com.example.backend.controller

import com.example.backend.config.security.JwtTokenUtil
import com.example.backend.model.Enums.PAYMENT
import com.example.backend.model.dto.ExpenseRequest
import com.example.backend.model.dto.ExpenseResponse
import com.example.backend.service.ExpenseService
import org.springframework.data.domain.Page
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime

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
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val createdExpense = expenseService.createExpense(expense, userId)

        return ResponseEntity.status(HttpStatus.CREATED)
            .body(createdExpense)
    }

    @PutMapping("/{id}")
    fun updateExpense(@RequestHeader("Authorization") authorizationHeader: String, @PathVariable id: Int, @RequestBody expense: ExpenseRequest): ResponseEntity<ExpenseResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

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
    fun getExpensesByCategoryId(@RequestHeader("Authorization") authorizationHeader: String, @PathVariable categoryId: Int): ResponseEntity<List<ExpenseResponse>> {
        
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()


        val expenses = expenseService.getExpensesByCategoryId(categoryId, userId)
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

    @GetMapping("/filter/date-range")
    fun getExpensesByDateRange(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam startDate: String,
        @RequestParam endDate: String
    ): ResponseEntity<List<ExpenseResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val start = LocalDateTime.parse(startDate)
        val end = LocalDateTime.parse(endDate)

        val expenses = expenseService.getExpensesByDateRange(userId, start, end)
        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/filter/amount-range")
    fun getExpensesByAmountRange(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam minAmount: Float,
        @RequestParam maxAmount: Float
    ): ResponseEntity<List<ExpenseResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val expenses = expenseService.getExpensesByAmountRange(userId, minAmount, maxAmount)
        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/filter/payment-method/{paymentMethod}")
    fun getExpensesByPaymentMethod(
        @RequestHeader("Authorization") authorizationHeader: String,
        @PathVariable paymentMethod: PAYMENT
    ): ResponseEntity<List<ExpenseResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val expenses = expenseService.getExpensesByPaymentMethod(userId, paymentMethod)
        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/analytics/total-spent")
    fun getTotalSpentBetween(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam startDate: String,
        @RequestParam endDate: String
    ): ResponseEntity<Map<String, Any>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val start = LocalDateTime.parse(startDate)
        val end = LocalDateTime.parse(endDate)

        val total = expenseService.getTotalSpentBetween(userId, start, end)

        return ResponseEntity.ok(mapOf(
            "totalSpent" to total,
            "startDate" to startDate,
            "endDate" to endDate,
            "currency" to "USD"
        ))
    }

    @GetMapping("/search")
    fun searchExpenses(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam query: String
    ): ResponseEntity<List<ExpenseResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val expenses = expenseService.searchExpenses(userId, query)
        return ResponseEntity.ok(expenses)
    }

    @GetMapping("/page")
    fun getExpensesPage(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<Page<ExpenseResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)

        val expensesPage = expenseService.getExpensesPage(userId, page, size)
        return ResponseEntity.ok(expensesPage)
    }

    private fun getUserIdFromToken(authorizationHeader: String): Int {
        val token = authorizationHeader.replace("Bearer ", "")
        return jwtTokenUtil.getUserId(token).toInt()
    }

}