package com.example.backend.model.dto

import com.example.backend.model.User
import java.time.LocalDateTime

data class UserRequest(
    val email: String,
    val password: String,
    val name: String?,
    val currency: String = "MKD",
)


data class UserResponse(
    val id: Int,
    val email: String,
    val name: String?,
    val currency: String,
    val createdAt: LocalDateTime,
    val password: String,
){
    companion object{
        fun fromEntity(user: User) : UserResponse{
            return UserResponse(
                id = user.id,
                email = user.email,
                name = user.name,
                currency = user.currency,
                createdAt = user.createdAt,
                password = user.password
            )
        }
    }
}