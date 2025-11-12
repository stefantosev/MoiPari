package com.example.backend.controller

import com.example.backend.config.security.JwtTokenUtil
import com.example.backend.model.User
import com.example.backend.model.dto.LoginDto
import com.example.backend.model.dto.UserRequest
import com.example.backend.model.dto.UserResponse
import com.example.backend.service.UserService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
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
class UserController(private val userService: UserService, private val passwordEncoder: BCryptPasswordEncoder, private val jwtTokenUtil: JwtTokenUtil) {

    @GetMapping
    fun getAllUsers(): ResponseEntity<List<UserResponse>> {
        return ResponseEntity.ok(userService.getUsers())
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: Int): ResponseEntity<UserResponse> {
        return ResponseEntity.ok(userService.getUserById(id))
    }

    @PostMapping
    fun createUser(@RequestBody user: UserRequest): ResponseEntity<UserResponse> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(userService.createUser(user))
    }

    @PutMapping("/{id}")
    fun updateUser(@PathVariable id: Int, @RequestBody user: UserRequest): ResponseEntity<UserResponse> {
        return ResponseEntity.ok(userService.updateUser(id, user))
    }

    @DeleteMapping("/{id}")
    fun deleteUser(@PathVariable id: Int): ResponseEntity<Void> {
        userService.deleteUser(id)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/register")
    fun register(@RequestBody user: UserRequest): Map<String, String> {

        val saved = userService.createUser(
            user.copy(password = user.password)
        )
        return mapOf("message" to "User registered", "id" to saved.id.toString())
    }


    @PostMapping("/login")
    fun login(@RequestBody loginDto: LoginDto): Map<String, String> {
        val user = userService.getByEmail(loginDto.email)

        if (!passwordEncoder.matches(loginDto.password, user.password)) {
            return mapOf("error" to "Invalid email or password")
        }

        val token = jwtTokenUtil.generateToken(user.email)
        return mapOf("token" to token, "type" to "Bearer")
    }

}