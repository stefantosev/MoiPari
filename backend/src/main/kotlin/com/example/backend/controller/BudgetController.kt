package com.example.backend.controller

import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.service.BudgetService
import org.springframework.http.ResponseEntity
import com.example.backend.config.security.JwtTokenUtil
import org.springframework.web.bind.annotation.*


@RestController
@RequestMapping("/api/budget")
class BudgetController(
    private val budgetService: BudgetService,
    private val jwtTokenUtil: JwtTokenUtil
) {

    @PostMapping
    fun createBudget(
        @RequestBody request: BudgetRequest,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<BudgetResponse> {
        val token = extractToken(authorizationHeader)
        val userId = jwtTokenUtil.getUserId(token).toInt()

        val createdBudget = budgetService.createBudget(request)
        return ResponseEntity.ok(createdBudget)
    }

    @PutMapping("/update/{id}")
    fun updateBudget(@PathVariable id: Int, @RequestBody request: BudgetRequest): ResponseEntity<BudgetResponse> {
        return ResponseEntity.ok(budgetService.updateBudget(id, request))
    }

    @DeleteMapping("/{id}")
    fun deleteBudget(@PathVariable id: Int): ResponseEntity<Void> {
        budgetService.deleteBudget(id)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/user/{userId}")
    fun getBudgetsByUser(@PathVariable userId: Int): ResponseEntity<List<BudgetResponse>> {
        val budgets = budgetService.getBudgetsByUser(userId)
        return ResponseEntity.ok(budgets)
    }

    @GetMapping("/check-limit")
    fun checkBudgetLimit(
        @RequestParam userId: Int,
        @RequestParam month: Int,
        @RequestParam year: Int
    ): ResponseEntity<Boolean> {
        val isLimitExceeded = budgetService.checkBudgetLimit(userId, month, year)
        return ResponseEntity.ok(isLimitExceeded)
    }

    @GetMapping("/convert-currency")
    fun convertCurrency(
        @RequestParam amount: Float,
        @RequestParam fromCurrency: String,
        @RequestParam toCurrency: String
    ): ResponseEntity<Float> {
        val convertedAmount = budgetService.convertCurrency(amount, fromCurrency, toCurrency)
        return ResponseEntity.ok(convertedAmount)
    }

    @GetMapping("/total-budget")
    fun getTotalBudget(
        @RequestParam userId: Int,
        @RequestParam month: Int,
        @RequestParam year: Int
    ): ResponseEntity<Float> {
        val totalBudget = budgetService.getTotalBudget(userId, month, year)
        return ResponseEntity.ok(totalBudget)
    }

    private fun extractToken(authorizationHeader: String): String {
        return authorizationHeader.replace("Bearer ", "")
    }
//    @GetMapping("/remaining-budget")
//    fun getRemainingBudget(
//        @RequestParam userId: Int,
//        @RequestParam month: Int,
//        @RequestParam year: Int
//    ): ResponseEntity<Float> {
//        val remainingBudget = budgetService.getRemainingBudget(userId, month, year)
//        return ResponseEntity.ok(remainingBudget)
//    }
}