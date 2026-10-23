package service

import (
	"context"
	"errors"
	"hrismdm/backend/internal/domain"
)

func (a *App) Inventory(ctx context.Context, actor domain.Actor) ([]domain.Inventory, error) {
	if actor.Role != "admin" {
		return nil, ErrForbidden
	}
	var out []domain.Inventory
	err := a.Store.List(ctx, "inventory", &out)
	return out, err
}
func (a *App) SaveInventory(ctx context.Context, actor domain.Actor, v domain.Inventory) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if v.Name == "" || v.Unit == "" || v.Stock < 0 || v.Minimum < 0 {
		return errors.New("data barang tidak valid")
	}
	return a.write(ctx, func(s domain.Store) error {
		if v.ID != "" {
			return errors.New("gunakan mutasi untuk mengubah stok")
		}
		v.ID = ID()
		if err := s.Put(ctx, "inventory", v.ID, v); err != nil {
			return err
		}
		m := domain.StockMovement{ID: ID(), ItemID: v.ID, Quantity: v.Stock, Note: "Stok awal", ActorID: actor.ID, CreatedAt: now()}
		if err := s.Put(ctx, "stock_movements", m.ID, m); err != nil {
			return err
		}
		return audit(ctx, s, actor, "inventory.create", v.ID)
	})
}
func (a *App) AdjustStock(ctx context.Context, actor domain.Actor, id string, quantity int, note string) error {
	if actor.Role != "admin" {
		return ErrForbidden
	}
	if quantity == 0 || quantity > 1000000 || quantity < -1000000 || note == "" {
		return errors.New("jumlah mutasi dan catatan wajib diisi")
	}
	return a.write(ctx, func(s domain.Store) error {
		var v domain.Inventory
		if err := s.Get(ctx, "inventory", id, &v); err != nil {
			return errors.New("barang tidak ditemukan")
		}
		if v.Stock+quantity < 0 {
			return errors.New("stok tidak mencukupi")
		}
		v.Stock += quantity
		if err := s.Put(ctx, "inventory", id, v); err != nil {
			return err
		}
		m := domain.StockMovement{ID: ID(), ItemID: id, Quantity: quantity, Note: note, ActorID: actor.ID, CreatedAt: now()}
		if err := s.Put(ctx, "stock_movements", m.ID, m); err != nil {
			return err
		}
		return audit(ctx, s, actor, "inventory.adjust", id)
	})
}
