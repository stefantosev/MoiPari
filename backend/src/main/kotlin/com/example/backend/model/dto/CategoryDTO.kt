package com.example.backend.model.dto;

import com.example.backend.model.Category

data class CategoryRequest(
    val name: String,
    val icon: String,
    val color: String,
    val userId: Int
)


data class CategoryResponse(
    val id: Int,
    val name: String,
    val icon: String,
    val color: String,
    val userId: Int
){
    companion object {
        fun fromEntity(category: Category) : CategoryResponse{
            return CategoryResponse(
                id = category.id,
                name = category.name,
                icon = category.icon,
                color = category.icon,
                userId = category.user?.id?:0
            )
        }
    }
}
