package com.example.backend.service.impl

import com.example.backend.model.User
import com.example.backend.repository.UserRepository
import com.example.backend.service.UserService
import org.springframework.stereotype.Service

@Service
class UserServiceImpl (private val userRepository: UserRepository) : UserService {
    override fun createUser(user: User): User {
        return userRepository.save(
            User(
                name = user.name,
                email = user.email,
                password = user.password,
            )
        )
    }

    override fun deleteUser(id: Int) {
        return userRepository.deleteById(id)
    }

    override fun updateUser(id: Int, updateUser: User): User? {
        userRepository.findById(id)
            .orElseThrow { Exception("User not found") }.let { existingUser ->

            val updatedUser = existingUser.copy(
                name = updateUser.name,
                email = updateUser.email,
                password = updateUser.password,
            )
            return userRepository.save(updatedUser)
        }
    }

    override fun getUsers(): List<User> {
        return userRepository.findAll()
    }

    override fun getUserById(id: Int): User {
        return userRepository.findById(id)
            .orElseThrow { Exception("User not found") }
    }
}