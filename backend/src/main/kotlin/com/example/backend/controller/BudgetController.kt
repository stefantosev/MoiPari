package com.example.backend.controller

import com.example.backend.model.Budget
import com.example.backend.service.BudgetService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*


@RestController
@RequestMapping("/api/budget")
class BudgetController(private val budgetService: BudgetService) {

    @PostMapping
    fun createBudget(@RequestBody budget: Budget, @RequestParam userId: Int): ResponseEntity<Budget> {
        val createdBudget = budgetService.createBudget(budget, userId)
        return ResponseEntity.ok(createdBudget)
    }

    @PutMapping("/update/{id}")
    fun updateBudget(@PathVariable id: Int, @RequestBody budget: Budget): ResponseEntity<Budget>? {
        return ResponseEntity.ok(budgetService.updateBudget(id, budget))
    }

    @DeleteMapping("/{id}")
    fun deleteBudget(@PathVariable id: Int): ResponseEntity<Void> {
        budgetService.deleteBudget(id)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/user/{userId}")
    fun getBudgetsByUser(@PathVariable userId: Int): ResponseEntity<List<Budget>> {
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
}