extends Node

signal on_ore_mined
signal on_miner_died
signal on_miner_cloned

func ore_mined(ore):
	emit_signal("on_ore_mined", ore)

func miner_died(miner):
	emit_signal("on_miner_died", miner)

func miner_cloned(miner):
	emit_signal("on_miner_cloned", miner)