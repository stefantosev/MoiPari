package com.example.backend.service.impl

import com.example.backend.model.User
import com.example.backend.model.dto.UserRequest
import com.example.backend.model.dto.UserResponse
import com.example.backend.repository.UserRepository
import com.example.backend.service.UserService
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserServiceImpl(private val userRepository: UserRepository, private val passwordEncoder: BCryptPasswordEncoder) : UserService {

    override fun createUser(request: UserRequest): UserResponse {
        val user = User(
            name = request.name,
            email = request.email,
            password = passwordEncoder.encode(request.password),
            currency = request.currency
        )
        val savedUser = userRepository.save(user)
        return UserResponse.fromEntity(savedUser)
    }

    override fun deleteUser(id: Int) {
        userRepository.deleteById(id)
    }

    override fun updateUser(id: Int, request: UserRequest): UserResponse {
        val existingUser = userRepository.findById(id)
            .orElseThrow { Exception("User not found") }

        val updatedUser = existingUser.copy(
            name = request.name,
            email = request.email,
            password = passwordEncoder.encode(request.password),
            currency = request.currency
        )
        val savedUser = userRepository.save(updatedUser)
        return UserResponse.fromEntity(savedUser)
    }

    override fun getUsers(): List<UserResponse> {
        return userRepository.findAll().map { UserResponse.fromEntity(it) }
    }

    override fun getUserById(id: Int): UserResponse {
        val user = userRepository.findById(id)
            .orElseThrow { Exception("User not found") }
        return UserResponse.fromEntity(user)
    }

    override fun getByEmail(email: String): UserResponse {
        val user = userRepository.findByEmail(email)
        return UserResponse.fromEntity(user)
    }
}