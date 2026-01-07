package com.example.backend.controller

import com.example.backend.model.dto.BudgetRequest
import com.example.backend.model.dto.BudgetResponse
import com.example.backend.service.BudgetService
import org.springframework.http.ResponseEntity
import com.example.backend.config.security.JwtTokenUtil
import org.springframework.web.bind.annotation.*
import java.time.LocalDateTime

@RestController
@RequestMapping("/api/budget")
class BudgetController(
    private val budgetService: BudgetService,
    private val jwtTokenUtil: JwtTokenUtil
) {


    @GetMapping("/current")
    fun getCurrentBudget(
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<BudgetResponse> {
        val userId = getUserIdFromToken(authorizationHeader)
        val budget = budgetService.getCurrentBudget(userId)
        return ResponseEntity.ok(budget)
    }

    @GetMapping("/month/{month}/{year}")
    fun getBudgetForMonth(
        @PathVariable month: Int,
        @PathVariable year: Int,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<BudgetResponse> {
        val userId = getUserIdFromToken(authorizationHeader)
        val budget = budgetService.getBudgetWithAnalytics(userId, month, year)
        return ResponseEntity.ok(budget)
    }

    @PostMapping
    fun createOrUpdateBudget(
        @RequestBody request: BudgetRequest,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<BudgetResponse> {
        val userId = getUserIdFromToken(authorizationHeader)

        val existingBudget = budgetService.getBudgetsByUser(userId)
            .firstOrNull { it.month == request.month && it.year == request.year }

        return if (existingBudget != null) {
            ResponseEntity.ok(budgetService.updateBudget(existingBudget.id, request, userId))
        } else {
            ResponseEntity.ok(budgetService.createBudget(request, userId))
        }
    }

    @PutMapping("/{id}")
    fun updateBudget(
        @PathVariable id: Int,
        @RequestBody request: BudgetRequest,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<BudgetResponse> {
        val userId = getUserIdFromToken(authorizationHeader)
        return ResponseEntity.ok(budgetService.updateBudget(id, request, userId))
    }

    @DeleteMapping("/{id}")
    fun deleteBudget(
        @PathVariable id: Int,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<Void> {
        val userId = getUserIdFromToken(authorizationHeader)
        budgetService.deleteBudget(id, userId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/my-budgets")
    fun getMyBudgets(
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<List<BudgetResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val budgets = budgetService.getBudgetsByUser(userId)
        return ResponseEntity.ok(budgets)
    }


    @GetMapping("/check-over-budget/{month}/{year}")
    fun checkOverBudget(
        @PathVariable month: Int,
        @PathVariable year: Int,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<Map<String, Boolean>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val isOver = budgetService.checkBudgetLimit(userId, month, year)
        return ResponseEntity.ok(mapOf("isOverBudget" to isOver))
    }
    @GetMapping("/remaining/{month}/{year}")
    fun getRemainingBudget(
        @PathVariable month: Int,
        @PathVariable year: Int,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<Map<String, Any>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val remaining = budgetService.getRemainingBudget(userId, month, year)
        val totalSpent = budgetService.getTotalSpent(userId, month, year)

        return ResponseEntity.ok(mapOf(
            "remaining" to remaining,
            "totalSpent" to totalSpent,
            "month" to month,
            "year" to year
        ))
    }
    @GetMapping("/history")
    fun getBudgetHistory(
        @RequestHeader("Authorization") authorizationHeader: String,
        @RequestParam(defaultValue = "6") months: Int
    ): ResponseEntity<List<BudgetResponse>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val history = budgetService.getBudgetProgress(userId, months)
        return ResponseEntity.ok(history)
    }
    @GetMapping("/total-spent/{month}/{year}")
    fun getTotalSpent(
        @PathVariable month: Int,
        @PathVariable year: Int,
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<Map<String, Any>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val totalSpent = budgetService.getTotalSpent(userId, month, year)

        return ResponseEntity.ok(mapOf(
            "totalSpent" to totalSpent,
            "month" to month,
            "year" to year,
            "userId" to userId
        ))
    }

    @GetMapping("/suggested")
    fun getSuggestedBudget(
        @RequestHeader("Authorization") authorizationHeader: String
    ): ResponseEntity<Map<String, Any>> {
        val userId = getUserIdFromToken(authorizationHeader)
        val suggested = budgetService.getSuggestedBudget(userId)
        val now = LocalDateTime.now()

        return ResponseEntity.ok(mapOf(
            "suggestedBudget" to suggested,
            "forMonth" to now.monthValue,
            "forYear" to now.year,
            "currency" to "USD"
        ))
    }


    private fun getUserIdFromToken(authorizationHeader: String): Int {
        val token = authorizationHeader.replace("Bearer ", "")
        return jwtTokenUtil.getUserId(token).toInt()
    }
}