package main

import (
	"github.com/gin-gonic/gin"
	"food-recipe-backend/controllers"
	"food-recipe-backend/middleware"
)

func main() {
	r := gin.Default()

	// Public routes
	r.POST("/signup", controller.Signup)
	r.POST("/login",controller.Login)

	// Apply JWT middleware to the following routes
	auth := r.Group("/")
	auth.Use(middleware.AuthMiddleware())
	{
		auth.GET("/profile", controller.Profile)
	}

	r.Run(":8080")
}
