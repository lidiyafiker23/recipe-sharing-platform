package auth

import (
	"fmt"
	"os"
	"time"
	"github.com/golang-jwt/jwt/v5"
)

var jwtKey = []byte(os.Getenv("SECRET"))

// GenerateToken creates a new JWT token
func GenerateToken(userID string, role string) (string, error) {
	claims := &jwt.MapClaims{
		"sub":  userID,
		"exp":  jwt.NewNumericDate(time.Now().Add(time.Hour * 24 * 30)),
		"role": role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}

// ParseToken parses and validates a JWT token
func ParseToken(tokenStr string) (*jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	return &claims, nil
}
