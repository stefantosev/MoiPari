package com.example.backend.model.dto;

import com.example.backend.model.Category

data class CategoryRequest(
    val name: String,
    val icon: String,
    val color: String,
)


data class CategoryResponse(
    val id: Int,
    val name: String,
    val icon: String,
    val color: String,
    val userId: Int,
    val expenseIds: List<Int>
){
    companion object {
        fun fromEntity(category: Category) : CategoryResponse{
            return CategoryResponse(
                id = category.id,
                name = category.name,
                icon = category.icon,
                color = category.color,
                userId = category.user?.id?:0,
                expenseIds =  category.expenses.map { it.id }
            )
        }
    }
}
