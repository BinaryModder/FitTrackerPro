package resolvers

import (
	"context"
	"github.com/BinaryModder/FitTrackerServer/internal/graph/model"
	"github.com/google/uuid"
)

// резолвер для Mutation createUser
func (r *Resolver) CreateUser(ctx context.Context, input model.NewUser) (*model.User, error) {
	user := &model.User{
		ID:        uuid.NewString(),
		Username:  input.Username,
		FirstName: input.FirstName,
		LastName:  input.LastName,
		Email:     input.Email,
		Password:  input.Password,
	}

	if err := r.DB.Create(user).Error; err != nil {
		return nil, err
	}

	return user, nil
}
