package db

type User struct {
	ID         string `gorm:"primaryKey"`
	Username   string
	Email      string
	First_name string
	Last_name  string
	Password   string
}
