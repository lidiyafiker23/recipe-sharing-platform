package controller

import (
	"bytes"
	"encoding/json"
	"food-recipe-backend/auth"
	"io"
	"net/http"
	"os"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// GraphQL request body
type requestBody struct {
	Query     string      `json:"query"`
	Variables interface{} `json:"variables,omitempty"`
}

func executeGraphQLQuery(query string, variables interface{}) ([]byte, error) {
	url := os.Getenv("HASURA_GRAPHQL_URL")
	reqBody := requestBody{
		Query:     query,
		Variables: variables,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonBody))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	return io.ReadAll(resp.Body)
}

// Signup handles user registration
func Signup(c *gin.Context) {
	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
		Username  string `json:"username"`
	}

	if err := c.BindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	mutation := `
		mutation ($email: String!, $password: String!) {
			insert_users_one(object: {email: $email, password: $password}) {
				id
			}
		}
	`

	_, err = executeGraphQLQuery(mutation, map[string]interface{}{
		"email":    body.Email,
		"password": string(hash),
		"username": body.Username,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User created successfully"})
}

// Login handles user authentication and JWT token generation
func Login(c *gin.Context) {
	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.BindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	query := `
		query ($email: String!) {
			users(where: {email: {_eq: $email}}) {
				id
				password
				role
			}
		}
	`

	response, err := executeGraphQLQuery(query, map[string]interface{}{
		"email": body.Email,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	var user struct {
		ID       string `json:"id"`
		Password string `json:"password"`
		Role     string `json:"role"`
	}

	err = json.Unmarshal(response, &user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse response"})
		return
	}

	if user.ID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email or password"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email or password"})
		return
	}

	// Use the GenerateToken function with the user's role
	tokenString, err := auth.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create token"})
		return
	}

	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("Authorization", tokenString, 3600*24*30, "/", "", false, true)
	c.JSON(http.StatusOK, gin.H{"token": tokenString})
}

// Profile retrieves user information from JWT
func Profile(c *gin.Context) {
	user, _ := c.Get("user")
	c.JSON(http.StatusOK, gin.H{"message": user})
}
