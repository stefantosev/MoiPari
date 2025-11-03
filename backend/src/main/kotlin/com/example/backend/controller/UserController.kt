package com.example.backend.controller

import com.example.backend.model.User
import com.example.backend.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/api/users")
class UserController(private val userService: UserService) {

    @GetMapping
    fun getAllUsers(): ResponseEntity<List<User>> {
        return ResponseEntity.ok(userService.getUsers())
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: Int): ResponseEntity<User> {
        return ResponseEntity.ok(userService.getUserById(id))
    }

    @PostMapping
    fun createUser(@RequestBody user: User): ResponseEntity<User> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(userService.createUser(user))
    }

    @PutMapping("/{id}")
    fun updateUser(@PathVariable id: Int, @RequestBody user: User): ResponseEntity<User> {
        return ResponseEntity.ok(userService.updateUser(id, user))
    }

    @DeleteMapping("{/id}")
    fun deleteUser(@PathVariable id: Int): ResponseEntity<Void> {
        userService.deleteUser(id)
        return ResponseEntity.noContent().build()
    }
}