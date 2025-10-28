package resolvers

import (
	"context"
	"github.com/BinaryModder/FitTrackerServer/internal/graph/model"
)

func (r *Resolver) Users(ctx context.Context) ([]*model.User, error) {
	var users []*model.User
	if err := r.DB.Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}
