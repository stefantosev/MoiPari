package com.example.backend.service

import com.example.backend.model.User

interface UserService {
    fun createUser(user: User) : User
    fun deleteUser(id: Int)
    fun updateUser(id: Int, updateUser: User) : User?
    fun getUsers() : List<User>
    fun getUserById(id: Int) : User
}