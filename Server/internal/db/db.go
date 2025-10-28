package db

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDataBase() (*gorm.DB, error) {

	db, err := gorm.Open(postgres.New(postgres.Config{DSN: "user=postgres password=12345 dbname=postgres port=5432 sslmode=disable TimeZone=Europe/London", PreferSimpleProtocol: true}), &gorm.Config{})

	if err != nil {
		return nil, err
	}

	if err := db.AutoMigrate(&User{}); err != nil {
		return nil, err
	}

	return db, nil
}
