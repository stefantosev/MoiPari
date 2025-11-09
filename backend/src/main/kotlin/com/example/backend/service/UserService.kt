package com.example.backend.service

import com.example.backend.model.User
import com.example.backend.model.dto.UserRequest
import com.example.backend.model.dto.UserResponse
import org.springframework.stereotype.Service

@Service
interface UserService {
    fun createUser(request: UserRequest): UserResponse
    fun deleteUser(id: Int)
    fun updateUser(id: Int, request: UserRequest): UserResponse?
    fun getUsers(): List<UserResponse>
    fun getUserById(id: Int): UserResponse
}