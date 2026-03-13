package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func ListLectures(c *gin.Context) {
	// TODO: Fetch from Firestore
	c.JSON(http.StatusOK, gin.H{
		"lectures": []interface{}{},
	})
}

func CreateLecture(c *gin.Context) {
	var req struct {
		Title      string  `json:"title"`
		PageWidth  float64 `json:"page_width"`
		PageHeight float64 `json:"page_height"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Create in Firestore
	c.JSON(http.StatusCreated, gin.H{
		"message": "Lecture created",
		"title":   req.Title,
	})
}

func GetLecture(c *gin.Context) {
	id := c.Param("id")
	// TODO: Fetch from Firestore
	c.JSON(http.StatusOK, gin.H{
		"id": id,
	})
}

func UpdateLecture(c *gin.Context) {
	id := c.Param("id")
	// TODO: Update in Firestore
	c.JSON(http.StatusOK, gin.H{
		"id":      id,
		"message": "Lecture updated",
	})
}

func DeleteLecture(c *gin.Context) {
	id := c.Param("id")
	// TODO: Delete from Firestore
	c.JSON(http.StatusOK, gin.H{
		"id":      id,
		"message": "Lecture deleted",
	})
}
