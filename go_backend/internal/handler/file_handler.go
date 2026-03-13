package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func UploadFile(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file uploaded"})
		return
	}

	// TODO: Save file and trigger conversion
	c.JSON(http.StatusOK, gin.H{
		"message":  "File uploaded successfully",
		"filename": file.Filename,
		"size":     file.Size,
	})
}

func ConvertFile(c *gin.Context) {
	var req struct {
		FileID string `json:"file_id" binding:"required"`
		Format string `json:"format" binding:"required"` // "pdf", "ppt", "doc", "hwp", "hwpx"
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: Implement file conversion pipeline
	// PDF -> poppler -> images
	// PPT/DOC -> LibreOffice headless -> images
	// HWP/HWPX -> hanpama/hwp + LibreOffice -> images

	c.JSON(http.StatusOK, gin.H{
		"message": "Conversion started",
		"file_id": req.FileID,
		"format":  req.Format,
		"status":  "processing",
	})
}
