package com.example.backend.config.security

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Component
import java.util.*
import javax.crypto.SecretKey

@Component
class JwtTokenUtil {
    private val secret = ""
    private val expiration = 6000000
    val key: SecretKey = Keys.hmacShaKeyFor(secret.toByteArray())


    fun generateToken(username: String) : String =
        Jwts.builder().subject(username).expiration(Date(System.currentTimeMillis() + expiration))
            .signWith(key, Jwts.SIG.HS512).compact()

    private fun getClaims(token: String) = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).payload

    fun getEmail(token: String) : String = getClaims(token).subject

    fun isTokenValid(token: String): Boolean {
        val claims = getClaims(token)
        val expirationDate = claims.expiration
        val now = Date(System.currentTimeMillis())
        return now.before(expirationDate)
    }
}