package com.example.backend.service.security

import com.example.backend.config.security.UserSecurity
import com.example.backend.repository.UserRepository
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import java.util.*

@Service
class UserDetailsService(
    private val repository: UserRepository
) : UserDetailsService {

    override fun loadUserByUsername(email: String) : UserDetails{

        val user = repository.findByEmail(email) ?: throw UsernameNotFoundException("$email not found")

        return UserSecurity(
            user.id.toString(),
            user.email,
            user.password,
            Collections.singleton(SimpleGrantedAuthority("user"))
        )
    }
}