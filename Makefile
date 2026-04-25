.PHONY: help install install-gui sync check test smoke clean restore uninstall

help:
	@echo "Targets:"
	@echo "  install       —— 部署 ~/.config/nvim（终端版）"
	@echo "  install-gui   —— 部署 + Neovide GUI"
	@echo "  sync          —— 把 ~/.config/nvim/ 同步回 templates/"
	@echo "  check         —— 跑 healthcheck.sh"
	@echo "  test          —— 跑 test/smoke.sh"
	@echo "  restore D=YYYYMMDD —— 回滚到指定日期备份"
	@echo "  uninstall     —— 一键卸载 nvim/neovide 及所有配置数据"

install:
	bash install.sh

install-gui:
	bash install.sh --gui

sync:
	rsync -a --delete \
	  --exclude=lazy-lock.json --exclude=lazy/ --exclude=mason/ \
	  ~/.config/nvim/lua/    templates/lua/
	rsync -a --delete ~/.config/nvim/snippets/ templates/snippets/
	rsync -a --delete ~/.config/nvim/after/    templates/after/
	cp ~/.config/nvim/CHEATSHEET.md templates/CHEATSHEET.md

check:
	bash healthcheck.sh

test smoke:
	bash test/smoke.sh

restore:
	@test -n "$(D)" || { echo "用法: make restore D=YYYYMMDD"; exit 1; }
	bash install.sh --restore $(D)

uninstall:
	bash install.sh --uninstall
