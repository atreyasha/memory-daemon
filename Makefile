PREFIX ?= /home/$(shell id -un)
CONF_PATH ?= $(PREFIX)/.config/mem_daemon

.PHONY: install
install:
ifeq ($(wildcard $(CONF_PATH)/md.conf),)
	install -Dm644 ./utils/md.conf $(CONF_PATH)/md.conf
endif
	install -Dm755 mem_daemon $(PREFIX)/bin/mem_daemon
	install -Dm755 mem_daemon_mail.py $(PREFIX)/bin/mem_daemon_mail

.PHONY: uninstall
uninstall:
	$(RM) $(PREFIX)/bin/mem_daemon $(PREFIX)/bin/mem_daemon_mail
	@crontab -l > $(CONF_PATH)/mycron
	@sed -i "/mem_daemon/d" $(CONF_PATH)/mycron
	@crontab $(CONF_PATH)/mycron
	$(RM) $(CONF_PATH)/mycron

.PHONY: test
test:
	mem_daemon 0 1

.PHONY: cronjob
cronjob:
	./utils/cronjob.sh $(PREFIX) $(CONF_PATH)
